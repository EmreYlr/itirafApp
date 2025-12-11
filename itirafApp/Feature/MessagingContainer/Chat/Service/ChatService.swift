//
//  ChatService.swift
//  itirafApp
//
//  Created by Emre on 23.10.2025.
//

import Foundation
import Alamofire

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
    func getRoomMessages(page: Int, limit: Int, with roomId: String) async throws -> RoomMessages
    func blockRoom(roomId: String) async throws
    func blockUser(userId: String) async throws
}

final class ChatService: ChatServiceProtocol {
    weak var delegate: ChatServiceDelegate?
    private var webSocketManager: WebSocketManagerProtocol
    private var networkService: NetworkService
    
    init(webSocketManager: WebSocketManagerProtocol = WebSocketManager.shared, networkService: NetworkService = NetworkManager.shared) {
        self.webSocketManager = webSocketManager
        self.networkService = networkService
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
    
    func getRoomMessages(page: Int, limit: Int, with roomId: String) async throws -> RoomMessages {
        let parameters: [String: Any] = [
            "page": page,
            "limit": limit
        ]
        
        return try await networkService.request(
            endpoint: Endpoint.Room.getRoomMessages(roomId: roomId),
            method: .get,
            parameters: parameters,
            encoding: URLEncoding.default
        )
    }
    
    func blockRoom(roomId: String) async throws {
        let parameters: [String: Any] = [
            "blockUser": true
        ]
        let _ : Empty = try await networkService.request(
            endpoint: Endpoint.Room.deleteRoom(roomId: roomId),
            method: .delete,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
    }
    
    func blockUser(userId: String) async throws {
        let parameters: [String: Any] = [
            "userId": userId
        ]
        let _ : Empty = try await networkService.request(
            endpoint: Endpoint.User.blockUser,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
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
