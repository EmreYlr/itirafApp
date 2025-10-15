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
}

final class DetailViewModel {
    weak var delegate: DetailViewModelOutputProtocol?
    var confession: ChannelMessageData?
    
    private let detailService: DetailServiceProtocol
    private let messageId: Int
    
    init(messageId: Int, detailService: DetailServiceProtocol = DetailService()) {
        self.detailService = detailService
        self.messageId =  messageId
    }

    func fetchMessageData() {
        detailService.fetchDetail(messageId: self.messageId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let messageData):
                    self?.confession = messageData
                    self?.delegate?.didFetchDetail()
                case .failure(let error):
                    self?.delegate?.didFailToFetchDetail(with: error)
                }
            }
        }
    }
    
    func likeMessage() {
        DispatchQueue.main.async {
            self.detailService.likeConfessions(messageId: self.messageId) { [weak self] result in
                switch result {
                case .success:
                    self?.toggleLike()
                case .failure(let error):
                    self?.delegate?.didFailToLikeMessage(with: error)
                    print("Error liking message: \(error)")
                }
            }
        }
    }
    
    func unlikeMessage() {
        DispatchQueue.main.async {
            self.detailService.unlikeConfessions(messageId: self.messageId) { [weak self] result in
                switch result {
                case .success:
                    self?.toggleLike()
                case .failure(let error):
                    self?.delegate?.didFailToLikeMessage(with: error)
                    print("Error unliking message: \(error)")
                }
            }
        }
    }
    
    func toggleLike() {
        guard var confession = confession else { return }
        confession.liked.toggle()
        confession.likeCount += confession.liked ? 1 : -1
        self.confession = confession
        delegate?.didUpdateLikeStatus(isLiked: confession.liked, likeCount: confession.likeCount)
    }
    
    func addComment(message: String) {
        //TODO: -Servis isteği atılacak
    }
}

extension DetailViewModel: DetailViewModelProtocol { }

