//
//  ChatService.swift
//  itirafApp
//
//  Created by Emre on 23.10.2025.
//

import Foundation

protocol ChatServiceDelegate: AnyObject {
    func chatDidReceive(message: String)
    func chatSessionFailed(with error: Error)
    func chatDidConnect()
    func chatDidDisconnect()
}

protocol ChatServiceProtocol {
    var delegate: ChatServiceDelegate? { get set }
    func startChatSession(roomId: String)
    func endChatSession()
    func sendMessage(_ text: String)
}

final class ChatService: ChatServiceProtocol {
    
    weak var delegate: ChatServiceDelegate?
    private var webSocketManager: WebSocketManagerProtocol
    
    init(webSocketManager: WebSocketManagerProtocol = WebSocketManager.shared) {
        self.webSocketManager = webSocketManager
        self.webSocketManager.delegate = self
    }
    
    func startChatSession(roomId: String) {
        let endpoint = Endpoint.Chat.chat(roomId: roomId)
        webSocketManager.connect(with: endpoint)
    }
    
    func endChatSession() {
        webSocketManager.disconnect()
    }
    
    func sendMessage(_ text: String) {
        webSocketManager.send(message: text)
    }
}

// MARK: - WebSocketManagerDelegate
extension ChatService: WebSocketManagerDelegate {
    func webSocketDidConnect() {
        delegate?.chatDidConnect()
    }
    
    func webSocketDidDisconnect() {
        delegate?.chatDidDisconnect()
    }
    
    func webSocketDidReceive(message: String) {
        delegate?.chatDidReceive(message: message)
    }
    
    func webSocketDidFail(with error: Error) {
        delegate?.chatSessionFailed(with: error)
    }
}
