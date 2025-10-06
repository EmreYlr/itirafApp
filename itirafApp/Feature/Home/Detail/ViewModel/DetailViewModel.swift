//
//  DetailViewModel.swift
//  itirafApp
//
//  Created by Emre on 6.10.2025.
//
import Foundation

protocol DetailViewModelProtocol {
    var delegate: DetailViewModelOutputProtocol? { get set }
    var confession: Confession? { get }
    var confessionReplies: [ChannelMessageReply] { get set }
    func toggleLike()
//    func fetchDetail(id: String)
}

protocol DetailViewModelOutputProtocol: AnyObject {
    func didFetchDetail()
    func didUpdateLikeStatus(isLiked: Bool, likeCount: Int)
    func didFailToFetchDetail(with error: Error)
}

final class DetailViewModel {
    weak var delegate: DetailViewModelOutputProtocol?
    var confession: Confession?
    var confessionReplies: [ChannelMessageReply] = [
        ChannelMessageReply(id: "1", message: "This is a reply to the confession. This is a reply to the confession. This is a reply to the confession. This is a reply to the confession.", targetMessageId: "1", ownerId: "user2", createdAt: Date()),
        ChannelMessageReply(id: "2", message: "Another reply to the confession.", targetMessageId: "1", ownerId: "user3", createdAt: Date())
    ]
    private let detailService: DetailServiceProtocol
    
    init(detailService: DetailServiceProtocol = DetailService(), confession: Confession) {
        self.detailService = detailService
        self.confession = confession
    }
    
    init(detailService: DetailServiceProtocol = DetailService()) {
        self.detailService = detailService
    }
    
    func toggleLike() {
        guard var confession = confession else { return }
        confession.isLiked.toggle()
        confession.likeCount += confession.isLiked ? 1 : -1
        self.confession = confession
        delegate?.didUpdateLikeStatus(isLiked: confession.isLiked, likeCount: confession.likeCount)
    }
}

extension DetailViewModel: DetailViewModelProtocol { }

