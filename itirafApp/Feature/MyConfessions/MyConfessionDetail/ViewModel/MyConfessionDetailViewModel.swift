//
//  MyConfessionDetailViewModel.swift
//  itirafApp
//
//  Created by Emre on 30.10.2025.
//

import Foundation

protocol MyConfessionDetailViewModelProtocol {
    var delegate: MyConfessionDetailViewModelDelegate? { get set }
    var myConfession: MyConfessionData? { get }
    func getModerationStatus() -> ConfessionDisplayStatus
    func deleteConfession() async
    func addComment(message: String) async
    func deleteReply(replyId: Int) async
    func blockUser(userId: String) async
    func createShortlink() async
    func getMaxReplyCharacterCount() -> Int
}

protocol MyConfessionDetailViewModelDelegate: AnyObject {
    func didDeleteConfession()
    func didUpdateReplies()
    func didDeleteReply()
    func didCreateShortlink(shortlink: String)
    func didError(error: Error)
}

final class MyConfessionDetailViewModel {
    weak var delegate: MyConfessionDetailViewModelDelegate?
    var myConfession: MyConfessionData?
    let myConfessionDetailService: MyConfessionDetailServiceProtocol
    private let maxReplyCharacterCount = 500
    
    init(myConfession: MyConfessionData? = nil, myConfessionDetailService: MyConfessionDetailServiceProtocol = MyConfessionDetailService()) {
        self.myConfession = myConfession
        self.myConfessionDetailService = myConfessionDetailService
    }
    
    func getModerationStatus() -> ConfessionDisplayStatus {
        switch myConfession?.moderationStatus {
        case .aiApproved, .humanApproved:
            return .approved
        case .aiRejected, .humanRejected:
            return .rejected
        case .needsHumanReview, .pending:
            return .inReview
        case .none:
            return .unknown
        }
    }
    
    func deleteConfession() async {
        guard let myConfession = myConfession else { return }
        do {
            try await myConfessionDetailService.deleteConfession(myConfession: myConfession)
            delegate?.didDeleteConfession()
        } catch {
            delegate?.didError(error: error)
        }
    }
    
    func addComment(message: String) async {
        guard var myConfession = myConfession else { return }
        let newReply = Reply(
            id: -1,
            message: message,
            owner: Owner(id: "-1", username: "You"),
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
 
        do {
            try await myConfessionDetailService.repliesMessage(message: message, messageId: myConfession.id)
            myConfession.replies?.append(newReply)
            self.myConfession?.replies = myConfession.replies
            delegate?.didUpdateReplies()
        } catch {
            delegate?.didError(error: error)
        }
    }
    
    func deleteReply(replyId: Int) async {
        do {
            try await myConfessionDetailService.deleteReply(replyId: replyId)
            myConfession?.replies?.removeAll(where: { $0.id == replyId })
            delegate?.didDeleteReply()
        } catch {
            delegate?.didError(error: error)
        }
    }
    
    func blockUser(userId: String) async {
        do {
            try await myConfessionDetailService.blockUser(userId: userId)
        } catch {
            delegate?.didError(error: error)
        }
    }
    
    func createShortlink() async {
        guard let myConfessionId = myConfession?.id else {
            return
        }
        
        do {
            let shortlink = try await myConfessionDetailService.createShortlink(messageId: myConfessionId)
            delegate?.didCreateShortlink(shortlink: shortlink.url)
        } catch {
            delegate?.didError(error: error)
        }
    }
    
    func getMaxReplyCharacterCount() -> Int {
        return maxReplyCharacterCount
    }
}
extension MyConfessionDetailViewModel: MyConfessionDetailViewModelProtocol { }
