//
//  DetailViewModel.swift
//  itirafApp
//
//  Created by Emre on 6.10.2025.
//
import Foundation

protocol DetailViewModelProtocol {
    var delegate: DetailViewModelOutputProtocol? { get set }
    var confession: ChannelMessageData? { get }
    func fetchMessageData() async
    func likeMessage() async
    func unlikeMessage() async
    func addComment(message: String) async
    func getChannelMessageId() -> Int
    func createShortlink() async
    func getTargetCommentId() -> Int?
    func getMaxReplyCharacterCount() -> Int
    func isNSFW() -> Bool
}

protocol DetailViewModelOutputProtocol: AnyObject {
    func didFetchDetail()
    func didUpdateLikeStatus(isLiked: Bool, likeCount: Int)
    func didFailToLikeMessage(with error: Error)
    func didFailToFetchDetail(with error: Error)
    func didUpdateReplies()
    func didFailToAddComment(with error: Error)
    func didCreateShortlink(shortlink: String)
    func didFailToCreateShortlink(with error: Error)
}

final class DetailViewModel {
    weak var delegate: DetailViewModelOutputProtocol?
    var confession: ChannelMessageData?
    private let maxReplyCharacterCount = 500
    
    private let detailService: DetailServiceProtocol
    private let messageId: Int
    private let commentId: Int?
    
    init(messageId: Int, commentId: Int? = nil, detailService: DetailServiceProtocol = DetailService()) {
        self.detailService = detailService
        self.messageId = messageId
        self.commentId = commentId
    }
    
    func fetchMessageData() async {
        do {
            let messageData = try await detailService.fetchDetail(messageId: messageId)
            confession = messageData
            await MainActor.run {
                delegate?.didFetchDetail()
            }
        } catch {
            await MainActor.run {
                delegate?.didFailToFetchDetail(with: error)
            }
        }
    }

    
    func likeMessage() async {
        do {
            try await detailService.likeConfessions(messageId: messageId)
            toggleLikeState()
        } catch {
            delegate?.didFailToLikeMessage(with: error)
        }
    }
    
    func unlikeMessage() async {
        do {
            try await detailService.unlikeConfessions(messageId: messageId)
            toggleLikeState()
        } catch {
            delegate?.didFailToLikeMessage(with: error)
        }
    }
    
    func addComment(message: String) async {
        let newReply = Reply(
            id: -1,
            message: message,
            owner: Owner(id: "-1", username: "You"),
            createdAt: ISO8601DateFormatter().string(from: Date())
        )

        do {
            try await detailService.repliesMessage(message: message, messageId: messageId)
            confession?.replies.append(newReply)
            await MainActor.run {
                delegate?.didUpdateReplies()
            }
        } catch {
            await MainActor.run {
                delegate?.didFailToAddComment(with: error)
            }
        }
    }
    
    func createShortlink() async {
        if let shortlink = confession?.shortlink {
            delegate?.didCreateShortlink(shortlink: shortlink)
            return
        }
        
        do {
            let shortlink = try await detailService.createShortlink(messageId: messageId)
            confession?.shortlink = shortlink.url
            delegate?.didCreateShortlink(shortlink: shortlink.url)
        } catch {
            delegate?.didFailToCreateShortlink(with: error)
        }
    }

    private func toggleLikeState() {
        guard var confession = confession else { return }
        confession.liked.toggle()
        confession.likeCount += confession.liked ? 1 : -1
        self.confession = confession
        
        Task { @MainActor in
            delegate?.didUpdateLikeStatus(isLiked: confession.liked, likeCount: confession.likeCount)
        }
    }

    
    func getChannelMessageId() -> Int {
        return messageId
    }
    
    func getTargetCommentId() -> Int? {
        return commentId
    }
    
    func getMaxReplyCharacterCount() -> Int {
        return maxReplyCharacterCount
    }
    
    func isNSFW() -> Bool {
        return confession?.isNsfw ?? false
    }
}

extension DetailViewModel: DetailViewModelProtocol { }
