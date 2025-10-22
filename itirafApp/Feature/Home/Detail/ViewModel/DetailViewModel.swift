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
    func toggleLike()
    func addComment(message: String)
    func fetchMessageData()
    func likeMessage()
    func unlikeMessage()
}

protocol DetailViewModelOutputProtocol: AnyObject {
    func didFetchDetail()
    func didUpdateLikeStatus(isLiked: Bool, likeCount: Int)
    func didFailToLikeMessage(with error: Error)
    func didFailToFetchDetail(with error: Error)
    func didUpdateReplies()
    func didFailToAddComment(with error: Error)
}


final class DetailViewModel {
    weak var delegate: DetailViewModelOutputProtocol?
    var confession: ChannelMessageData?
    
    private let detailService: DetailServiceProtocol
    private let messageId: Int
    
    init(messageId: Int, detailService: DetailServiceProtocol = DetailService()) {
        self.detailService = detailService
        self.messageId = messageId
    }
    
    func fetchMessageData() {
        Task.detached { [weak self] in
            guard let self = self else { return }
            do {
                let messageData = try await self.detailService.fetchDetail(messageId: self.messageId)
                await MainActor.run {
                    self.confession = messageData
                    self.delegate?.didFetchDetail()
                }
            } catch {
                await MainActor.run {
                    self.delegate?.didFailToFetchDetail(with: error)
                }
            }
        }
    }
    
    func likeMessage() {
        Task.detached { [weak self] in
            guard let self = self else { return }
            do {
                _ = try await self.detailService.likeConfessions(messageId: self.messageId)
                await MainActor.run {
                    self.toggleLike()
                }
            } catch {
                await MainActor.run {
                    self.delegate?.didFailToLikeMessage(with: error)
                }
                print("Error liking message: \(error)")
            }
        }
    }
    
    func unlikeMessage() {
        Task.detached { [weak self] in
            guard let self = self else { return }
            do {
                _ = try await self.detailService.unlikeConfessions(messageId: self.messageId)
                await MainActor.run {
                    self.toggleLike()
                }
            } catch {
                await MainActor.run {
                    self.delegate?.didFailToLikeMessage(with: error)
                }
                print("Error unliking message: \(error)")
            }
        }
    }
    
    func addComment(message: String) {
        Task.detached { [weak self] in
            guard let self = self else { return }
            do {
                _ = try await self.detailService.repliesMessage(message: message, messageId: self.messageId)
                await MainActor.run {
                    self.delegate?.didUpdateReplies()
                }
                print("Comment added successfully")
            } catch {
                await MainActor.run {
                    self.delegate?.didFailToAddComment(with: error)
                }
                print("Failed to add comment: \(error)")
            }
        }
    }
    
    @MainActor
    func toggleLike() {
        guard var confession = confession else { return }
        confession.liked.toggle()
        confession.likeCount += confession.liked ? 1 : -1
        self.confession = confession
        delegate?.didUpdateLikeStatus(isLiked: confession.liked, likeCount: confession.likeCount)
    }
}

extension DetailViewModel: @preconcurrency DetailViewModelProtocol { }

