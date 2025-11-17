//
//  DirectMessageViewModel.swift
//  itirafApp
//
//  Created by Emre on 22.10.2025.
//

protocol DirectMessageViewModelProtocol {
    var delegate: DirectMessageViewModelDelegate? { get set }
    var directMessages: [DirectMessage] { get }
    func fetchDirectMessages() async
    func deleteRoom(roomId: String, blockUser: Bool) async
}

protocol DirectMessageViewModelDelegate: AnyObject {
    func didUpdateDirectMessages()
    func didError(_ error: Error)
}

final class DirectMessageViewModel {
    weak var delegate: DirectMessageViewModelDelegate?
    private var directMessageService: DirectMessageServiceProtocol
    
    var directMessages: [DirectMessage] = []

    init(directMessageService: DirectMessageServiceProtocol = DirectMessageService()) {
        self.directMessageService = directMessageService
    }
    
    func fetchDirectMessages() async {
        do {
            let rooms = try await directMessageService.getAllRoom()
            self.directMessages = rooms
            delegate?.didUpdateDirectMessages()
        } catch {
            delegate?.didError(error)
        }
        
    }
    
    func deleteRoom(roomId: String, blockUser: Bool) async {
        do {
            try await directMessageService.deleteRoom(roomId: roomId, blockUser: blockUser)
            if let index = directMessages.firstIndex(where: { $0.roomID == roomId }) {
                directMessages.remove(at: index)
                delegate?.didUpdateDirectMessages()
            }
        } catch {
            delegate?.didError(error)
        }
    }
}

extension DirectMessageViewModel: DirectMessageViewModelProtocol { }
