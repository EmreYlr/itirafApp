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
    
    private override init() {
        super.init()
        self.urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
    }
    
    func connect(with endpoint: EndpointType) {
        do {
            try checkAuthenticationIfNeeded(for: endpoint)
        } catch {
            delegate?.webSocketDidFail(with: error)
            return
        }
        
        disconnect()
        
        guard let url = URL(string: NetworkConstants.webSocketURL + endpoint.path) else {
            delegate?.webSocketDidFail(with: APIError(code: 0, type: "URLError", message: "Invalid URL"))
            return
        }
        
        var request = URLRequest(url: url)
        
        if let token = AuthManager.shared.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.setValue(Constants.clientKey, forHTTPHeaderField: "x-client-key")
        
        webSocketTask = urlSession.webSocketTask(with: request)
        webSocketTask?.resume()
        receiveMessage()
        print("🔗 WebSocket bağlantısı kuruluyor: \(url.absoluteString)")
    }
    
    func disconnect() {
        stopPinging()
        
        guard webSocketTask != nil else { return }
        
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.webSocketDidDisconnect()
        }
    }
    
    func send(message: String) {
        guard webSocketTask?.state == .running else {
            print("❌ WebSocket bağlı değil. Mesaj gönderilemedi.")
            return
        }
        
        let messageData = WebSocketMessageData(content: message)
        let requestObject = WebSocketRequest(type: "message", data: messageData)
        
        let encoder = JSONEncoder()
        guard let jsonData = try? encoder.encode(requestObject) else {
            print("❌ WebSocket mesajı JSON'a çevirme hatası.")
            return
        }
        
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("❌ WebSocket JSON string'e çevirme hatası.")
            return
        }
        
        
        let wsMessage = URLSessionWebSocketTask.Message.string(jsonString)
        webSocketTask?.send(wsMessage) { error in
            if let error = error {
                print("❌ WebSocket mesaj gönderme hatası: \(error.localizedDescription)")
            }
        }
    }
    
    func sendSeenStatus() {
        guard webSocketTask?.state == .running else {
            print("❌ WebSocket bağlı değil. 'Seen' durumu gönderilemedi.")
            return
        }
        
        let requestObject = SeenRequest(type: "seen")
        
        let encoder = JSONEncoder()
        guard let jsonData = try? encoder.encode(requestObject),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("❌ WebSocket 'seen' mesajı JSON'a çevirme hatası.")
            return
        }
        
        let wsMessage = URLSessionWebSocketTask.Message.string(jsonString)
        webSocketTask?.send(wsMessage) { error in
            if let error = error {
                print("❌ WebSocket 'seen' gönderme hatası: \(error.localizedDescription)")
            }
        }
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                if case .string(let text) = message {
                    DispatchQueue.main.async {
                        self?.delegate?.webSocketDidReceive(message: text)
                    }
                }
                self?.receiveMessage()
            case .failure(let error):
                self?.disconnect()
                DispatchQueue.main.async {
                    self?.delegate?.webSocketDidFail(with: error)
                }
            }
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
            print("🔻 Ping gönderilemedi, bağlantı aktif değil. Pinger durduruluyor.")
            stopPinging()
            return
        }
        
        task.sendPing { error in
            if let error = error {
                print("❌ Ping gönderme hatası: \(error.localizedDescription)")
                self.disconnect()
            } else {
                print("👍 Ping gönderildi, bağlantı canlı.")
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
        self.sendSeenStatus()
        DispatchQueue.main.async {
            self.delegate?.webSocketDidConnect()
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        stopPinging()
        DispatchQueue.main.async {
            self.delegate?.webSocketDidDisconnect()
        }
    }
}
