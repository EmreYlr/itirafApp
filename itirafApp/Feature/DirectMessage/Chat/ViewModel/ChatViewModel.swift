//
//  ChatViewModel.swift
//  itirafApp
//
//  Created by Emre on 23.10.2025.
//

protocol ChatViewModelProtocol {
    var delegate: ChatViewModelDelegate? { get set }
    var directMessage: DirectMessage? { get set }
}

protocol ChatViewModelDelegate: AnyObject {
    func didUpdateChat()
    func diderror(_ error: Error)
}

final class ChatViewModel {
    weak var delegate: ChatViewModelDelegate?
    var chatService: ChatServiceProtocol
    var directMessage: DirectMessage?
    
    init(chatService: ChatServiceProtocol = ChatService()) {
        self.chatService = chatService
    }
}

extension ChatViewModel: ChatViewModelProtocol { }
