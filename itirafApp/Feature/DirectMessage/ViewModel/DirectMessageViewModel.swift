//
//  DirectMessageViewModel.swift
//  itirafApp
//
//  Created by Emre on 22.10.2025.
//

protocol DirectMessageViewModelProtocol {
    var delegate: DirectMessageViewModelDelegate? { get set }
    var directMessages: [DirectMessage] { get }
    func fetchDirectMessages()
}

protocol DirectMessageViewModelDelegate: AnyObject {
    func didUpdateDirectMessages()
    func didError(_ error: Error)
}

final class DirectMessageViewModel {
    weak var delegate: DirectMessageViewModelDelegate?
    private var directMessageService: DirectMessageServiceProtocol
    
    var directMessages: [DirectMessage] = [
        DirectMessage(id: 1, senderUsername: "Anonymous", senderId: "1", receiverId: "1", message: "Bu bir test mesajıdır", createdAt: "14:30"),
        DirectMessage(id: 2, senderUsername: "Anonymous", senderId: "1", receiverId: "1", message: "Bu bir test mesajıdır", createdAt: "14:30"),
        DirectMessage(id: 3, senderUsername: "Anonymous", senderId: "1", receiverId: "1", message: "Bu bir test mesajıdır", createdAt: "14:30"),
        DirectMessage(id: 4, senderUsername: "Anonymous", senderId: "1", receiverId: "1", message: "Bu bir test mesajıdır", createdAt: "14:30"),
    ]
    
    init(directMessageService: DirectMessageServiceProtocol = DirectMessageService()) {
        self.directMessageService = directMessageService
    }
    
    func fetchDirectMessages() {
        delegate?.didUpdateDirectMessages()
    }
    
}

extension DirectMessageViewModel: DirectMessageViewModelProtocol { }
