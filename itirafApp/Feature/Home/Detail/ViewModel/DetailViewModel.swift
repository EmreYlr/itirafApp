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
}

protocol DetailViewModelOutputProtocol: AnyObject {
    func didFetchDetail()
    func didUpdateLikeStatus(isLiked: Bool, likeCount: Int)
    func didFailToLikeMessage(with error: Error)
    func didFailToFetchDetail(with error: Error)
    func didUpdateReplies()
    func didFailToAddComment(with error: Error)
}


@MainActor
final class DetailViewModel {
    weak var delegate: DetailViewModelOutputProtocol?
    var confession: ChannelMessageData?
    
    private let detailService: DetailServiceProtocol
    private let messageId: Int
    
    init(messageId: Int, detailService: DetailServiceProtocol = DetailService()) {
        self.detailService = detailService
        self.messageId = messageId
    }
    
    func fetchMessageData() async {
        do {
            let messageData = try await detailService.fetchDetail(messageId: messageId)
            confession = messageData
            delegate?.didFetchDetail()
        } catch {
            delegate?.didFailToFetchDetail(with: error)
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
            delegate?.didUpdateReplies()
        } catch {
            delegate?.didFailToAddComment(with: error)
        }
    }
    private func toggleLikeState() {
        guard var confession = confession else { return }
        confession.liked.toggle()
        confession.likeCount += confession.liked ? 1 : -1
        self.confession = confession
        delegate?.didUpdateLikeStatus(isLiked: confession.liked, likeCount: confession.likeCount)
    }
}

extension DetailViewModel: @preconcurrency DetailViewModelProtocol { }
