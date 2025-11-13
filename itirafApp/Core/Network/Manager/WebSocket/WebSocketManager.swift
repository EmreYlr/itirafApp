//
//  WebSocketManagerDelegate.swift
//  itirafApp
//
//  Created by Emre on 24.10.2025.
//

import Foundation

// MARK: - WebSocketManager Delegate
protocol WebSocketManagerDelegate: AnyObject {
    func webSocketDidConnect()
    func webSocketDidDisconnect()
    func webSocketDidReceive(message: String)
    func webSocketDidFail(with error: Error)
}

// MARK: - WebSocketManager Protocol
protocol WebSocketManagerProtocol {
    var delegate: WebSocketManagerDelegate? { get set }
    func connect(with endpoint: EndpointType)
    func disconnect()
    func send(message: String)
}

final class WebSocketManager: NSObject, WebSocketManagerProtocol {
    static let shared = WebSocketManager()
    
    weak var delegate: WebSocketManagerDelegate?
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession!
    private var pingTimer: Timer?
    private var lastConnectedEndpoint: EndpointType?
    private var pendingMessage: String?
    
    private override init() {
        super.init()
        self.urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
    }
    
    func connect(with endpoint: EndpointType) {
        do {
            try checkAuthenticationIfNeeded(for: endpoint)
        } catch {
            print("❌ connect: authentication hatası \(error)")
            delegate?.webSocketDidFail(with: error)
            return
        }
        
        disconnect()
        lastConnectedEndpoint = endpoint
        
        guard let url = URL(string: NetworkConstants.webSocketURL + endpoint.path) else {
            let err = APIError(code: 0, type: "URLError", message: "Invalid URL")
            print("❌ connect: URL hatası")
            delegate?.webSocketDidFail(with: err)
            return
        }
        
        var request = URLRequest(url: url)
        if let token = AuthManager.shared.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.setValue(Constants.clientKey, forHTTPHeaderField: "x-client-key")
        
        webSocketTask = urlSession.webSocketTask(with: request)
        webSocketTask?.resume()
        sendSeenRequest()
        receiveMessage()
    }
    
    func disconnect() {
        guard let task = webSocketTask else {
            return
        }
        task.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
    }
    
    func send(message: String) {
        pendingMessage = message
        
        guard let task = webSocketTask, task.state == .running else {
            print("⚠️ send: WebSocket bağlı değil, mesaj beklemeye alındı")
            return
        }
        
//        guard let userId = UserManager.shared.getUserID() else {
//            print("❌ send: kullanıcı ID alınamadı")
//            return
//        }
        
        let messageData = WebSocketMessageData(content: message)
        let requestObject = WebSocketRequest(type: "message", data: messageData)
        
        guard let jsonData = try? JSONEncoder().encode(requestObject),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("❌ send: JSON encode hatası")
            return
        }
        
        webSocketTask?.send(.string(jsonString)) { error in
            if let error = error {
                print("❌ send: gönderme hatası \(error.localizedDescription)")
            }
        }
    }

    private func sendSeenRequest() {
        let seenRequest = SeenRequest()
        
        if let jsonData = try? JSONEncoder().encode(seenRequest),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            webSocketTask?.send(.string(jsonString)) { error in
                if let error = error {
                    print("❌ connect: Seen mesaj gönderme hatası \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                if case .string(let text) = message {
                    DispatchQueue.main.async {
                        self.delegate?.webSocketDidReceive(message: text)
                    }
                }
                self.receiveMessage()
            case .failure(let error):
                guard self.webSocketTask != nil else {
                    return
                }
                print("❌ receiveMessage: hata \(error.localizedDescription)")
            }
        }
    }

    private func handleExpiredToken() async {
        print("🔄 handleExpiredToken: token yenileniyor...")
        let success = await AuthService.refreshToken()
        if success {
            print("✅ handleExpiredToken: token yenilendi, reconnect başlatılıyor")
            if let endpoint = lastConnectedEndpoint {
                connect(with: endpoint)
            }
        } else {
            print("❌ handleExpiredToken: token yenilenemedi")
        }
    }

    private func startPinging() {
        stopPinging()
        DispatchQueue.main.async {
            self.pingTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
                self?.sendPing()
            }
        }
    }
    
    private func stopPinging() {
        pingTimer?.invalidate()
        pingTimer = nil
    }
    
    private func sendPing() {
        guard let task = webSocketTask, task.state == .running else {
            print("🔻 sendPing: bağlantı yok, ping gönderilemiyor")
            stopPinging()
            return
        }
        
        task.sendPing { [weak self] error in
            if let error = error {
                print("❌ sendPing: hata \(error.localizedDescription)")
                self?.disconnect()
            } else {
                print("👍 sendPing: başarılı")
            }
        }
    }
    
    private func checkAuthenticationIfNeeded(for endpoint: EndpointType) throws {
        guard endpoint.requiresAuth, UserManager.shared.getUserIsAnonymous() else { return }
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .loginRequired, object: nil)
        }
        throw APIError(code: 401, type: "AuthError", message: "Authentication required for WebSocket")
    }
}

// MARK: - URLSessionWebSocketDelegate
extension WebSocketManager: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        startPinging()
        if let pendingMessage = pendingMessage {
            send(message: pendingMessage)
            self.pendingMessage = nil
        }
        DispatchQueue.main.async {
            self.delegate?.webSocketDidConnect()
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        if closeCode.rawValue == 4402 {
            Task { await self.handleExpiredToken() }
        } else {
            self.pendingMessage = nil
            stopPinging()
            DispatchQueue.main.async {
                self.delegate?.webSocketDidDisconnect()
            }
        }
    }
}
