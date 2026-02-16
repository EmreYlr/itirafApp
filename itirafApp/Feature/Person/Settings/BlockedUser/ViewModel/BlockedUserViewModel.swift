//
//  BlockedUserViewModel.swift
//  itirafApp
//
//  Created by Emre on 16.02.2026.
//

protocol BlockedUserViewModelProtocol {
    var delegate: BlockedUserViewModelDelagete? { get set }
    var blockedUsers: [BlockedUser] { get set }
    func fetchBlockedUsers() async
    func unblockUser(userId: String) async
    func getBlockedUserCount() -> Int
}

protocol BlockedUserViewModelDelagete: AnyObject {
    func didUnblockUserSuccessfully(_ userId: String)
    func didFetchBlockedUsersSuccessfully()
    func didEmptyUserBlocks()
    func didError(with error: Error)
}

final class BlockedUserViewModel {
    weak var delegate: BlockedUserViewModelDelagete?
    let service: BlockedUserServiceProtocol
    
    var blockedUsers: [BlockedUser] = []
    
    init(service: BlockedUserServiceProtocol = BlockedUserService()) {
        self.service = service
    }
    
    func fetchBlockedUsers() async {
        do {
            blockedUsers = try await service.fetchBlockedUsers()
            delegate?.didFetchBlockedUsersSuccessfully()
        } catch {
            delegate?.didError(with: error)
        }
    }
    
    func unblockUser(userId: String) async {
        do {
            try await service.unblockUser(userId: userId)
            delegate?.didUnblockUserSuccessfully(userId)
        } catch {
            delegate?.didError(with: error)
        }
    }
    
    func getBlockedUserCount() -> Int {
        if blockedUsers.isEmpty {
            delegate?.didEmptyUserBlocks()
            return 0
        }
        return blockedUsers.count
    }
    
}

extension BlockedUserViewModel: BlockedUserViewModelProtocol { }

