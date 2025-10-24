//
//  ChatViewModel.swift
//  itirafApp
//
//  Created by Emre on 23.10.2025.
//

import Foundation
import MessageKit

protocol ChatViewModelProtocol {
    var delegate: ChatViewModelDelegate? { get set }
    var directMessage: DirectMessage? { get set }
    var messages: [Message] { get }
    var currentSender: Sender { get }
    func startListening()
    func stopListening()
    func sendMessage(_ text: String)
}

protocol ChatViewModelDelegate: AnyObject {
    func didUpdateMessages()
    func diderror(_ error: Error)
}

final class ChatViewModel: NSObject {
    weak var delegate: ChatViewModelDelegate?
    var directMessage: DirectMessage?
    
    private(set) var messages: [Message] = []
    private(set) var currentSender: Sender
    
    private var chatService: ChatServiceProtocol
    private var isConnected = false
    
    init(chatService: ChatServiceProtocol = ChatService()) {
        self.chatService = chatService
        self.currentSender = Sender(senderId: UserManager.shared.getUser()?.id ?? "", displayName: "Ben")
        super.init()
        self.chatService.delegate = self
    }
    
    func startListening() {
        guard let roomId = directMessage?.roomId else {
            let error = APIError(code: 0, type: "MissingInfo", message: "Room ID not found to start listening.")
            delegate?.diderror(error)
            return
        }
        chatService.startChatSession(roomId: roomId)
    }
    
    func stopListening() {
        chatService.endChatSession()
    }
    
    func sendMessage(_ text: String) {
        let newMessage = Message(sender: currentSender, messageId: UUID().uuidString, sentDate: Date(), kind: .text(text))
        messages.append(newMessage)
        delegate?.didUpdateMessages()
        
        if isConnected {
            chatService.sendMessage(text)
        } else {
            print("⚠️ Mesaj gönderilemedi, bağlantı yok.")
        }
    }
    
    deinit {
        stopListening()
    }
    
    
}

extension ChatViewModel: ChatViewModelProtocol { }

extension ChatViewModel: ChatServiceDelegate {
    
    func chatDidConnect() {
        isConnected = true
        print("🟢 ViewModel: Chat oturumu aktif.")
    }
    
    func chatDidDisconnect() {
        isConnected = false
        print("🔴 ViewModel: Chat oturumu kapandı.")
    }
    
    func chatDidReceive(message: String) {
        let otherSender = Sender(senderId: directMessage?.senderId ?? "other_user", displayName: directMessage?.senderUsername ?? "Karşı Taraf")
        let newMessage = Message(sender: otherSender, messageId: UUID().uuidString, sentDate: Date(), kind: .text(message))
        messages.append(newMessage)
        delegate?.didUpdateMessages()
    }
    
    func chatSessionFailed(with error: Error) {
        isConnected = false
        print("❌ ViewModel: Chat oturumu başlatılamadı. Hata: \(error.localizedDescription)")
    }
}
