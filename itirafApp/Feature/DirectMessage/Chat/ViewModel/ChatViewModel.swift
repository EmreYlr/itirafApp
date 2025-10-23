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
    
    func loadMockMessages()
    func sendMessage(_ text: String)
}

protocol ChatViewModelDelegate: AnyObject {
    func didUpdateMessages()
    func diderror(_ error: Error)
}

final class ChatViewModel {
    weak var delegate: ChatViewModelDelegate?
    var chatService: ChatServiceProtocol
    var directMessage: DirectMessage?

    private(set) var messages: [Message] = []
    private(set) var currentSender: Sender
    
    init(chatService: ChatServiceProtocol = ChatService()) {
        self.chatService = chatService
        
        self.currentSender = Sender(senderId: "current_user", displayName: "Ben")
    }
    func loadMockMessages() {
        let otherSender = Sender(
            senderId: directMessage?.senderId ?? "other_user",
            displayName: directMessage?.senderUsername ?? "Diğer Kullanıcı"
        )
        
        let mockMessages: [Message] = [
            Message(
                sender: otherSender,
                messageId: UUID().uuidString,
                sentDate: Date().addingTimeInterval(-3600),
                kind: .text("Merhaba!")
            ),
            Message(
                sender: currentSender,
                messageId: UUID().uuidString,
                sentDate: Date().addingTimeInterval(-3500),
                kind: .text("Selam, nasılsın?")
            ),
            Message(
                sender: otherSender,
                messageId: UUID().uuidString,
                sentDate: Date().addingTimeInterval(-3400),
                kind: .text("İyiyim teşekkürler, sen?")
            ),
            Message(
                sender: currentSender,
                messageId: UUID().uuidString,
                sentDate: Date().addingTimeInterval(-3300),
                kind: .text("Ben de iyiyim 😊")
            ),
            Message(
                sender: otherSender,
                messageId: UUID().uuidString,
                sentDate: Date().addingTimeInterval(-1800),
                kind: .text("Bugün ne yapıyorsun?")
            ),
            Message(
                sender: currentSender,
                messageId: UUID().uuidString,
                sentDate: Date().addingTimeInterval(-1700),
                kind: .text("Proje üzerinde çalışıyorum. MessageKit entegre ediyorum.")
            )
        ]
        
        self.messages = mockMessages
        delegate?.didUpdateMessages()
    }
    
    // Mesaj gönder (mock)
    func sendMessage(_ text: String) {
        let newMessage = Message(
            sender: currentSender,
            messageId: UUID().uuidString,
            sentDate: Date(),
            kind: .text(text)
        )
        
        messages.append(newMessage)
        delegate?.didUpdateMessages()
        
        // İleride WebSocket ile gönderilecek
        // chatService.sendMessage(text, to: receiverId)
        
        // Mock cevap simülasyonu
        simulateMockResponse()
    }
    
    private func simulateMockResponse() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            
            let otherSender = Sender(
                senderId: self.directMessage?.senderId ?? "other_user",
                displayName: self.directMessage?.senderUsername ?? "Diğer Kullanıcı"
            )
            
            let responses = [
                "Anladım 👍",
                "Harika!",
                "Güzel görünüyor",
                "Evet, katılıyorum",
                "İlginç..."
            ]
            
            let randomResponse = responses.randomElement() ?? "Tamam"
            
            let responseMessage = Message(
                sender: otherSender,
                messageId: UUID().uuidString,
                sentDate: Date(),
                kind: .text(randomResponse)
            )
            
            self.messages.append(responseMessage)
            self.delegate?.didUpdateMessages()
        }
    }
}

extension ChatViewModel: ChatViewModelProtocol { }
