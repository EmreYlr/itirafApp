//
//  DetailViewModel.swift
//  itirafApp
//
//  Created by Emre on 6.10.2025.
//
import Foundation

protocol DetailViewModelProtocol {
    var delegate: DetailViewModelOutputProtocol? { get set }
    var confession: ConfessionData? { get }
    var confessionReplies: [Reply] { get set }
    func toggleLike()
    func addComment(message: String)
    func fetchMessageData()
}

protocol DetailViewModelOutputProtocol: AnyObject {
    func didFetchDetail()
    func didUpdateLikeStatus(isLiked: Bool, likeCount: Int)
    func didFailToFetchDetail(with error: Error)
}

final class DetailViewModel {
    weak var delegate: DetailViewModelOutputProtocol?
    var confession: ConfessionData?
    var confessionReplies: [Reply] = []
    
    private let detailService: DetailServiceProtocol
    
    init(detailService: DetailServiceProtocol = DetailService(), confession: ConfessionData) {
        self.detailService = detailService
        self.confession = confession
    }
    
    init(detailService: DetailServiceProtocol = DetailService()) {
        self.detailService = detailService
    }
    
    func fetchMessageData() {
        guard let messageId = confession?.id else {
            return
        }
        detailService.fetchDetail(messageId: messageId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let messageData):
                    self?.confessionReplies = messageData.replies
                    self?.delegate?.didFetchDetail()
                case .failure(let error):
                    self?.delegate?.didFailToFetchDetail(with: error)
                }
            }
        }
    }
    
    func toggleLike() {
//        guard var confession = confession else { return }
//        confession.isLiked.toggle()
//        confession.likeCount += confession.isLiked ? 1 : -1
//        self.confession = confession
//        delegate?.didUpdateLikeStatus(isLiked: confession.isLiked, likeCount: confession.likeCount)
    }
    
    func addComment(message: String) {
        //TODO: -Servis isteği atılacak
    }
}

extension DetailViewModel: DetailViewModelProtocol { }

