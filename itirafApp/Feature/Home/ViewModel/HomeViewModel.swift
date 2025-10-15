//
//  HomeViewModel.swift
//  itirafApp
//
//  Created by Emre on 16.09.2025.
//
import Foundation

protocol HomeViewModelProtocol {
    var delegate: HomeViewModelOutputProtocol? { get set }
    var confessions: Confession? { get set }
    var isLoading: Bool { get }
    var hasMoreData: Bool { get }
    func fetchConfessions(reset: Bool)
    func likeMessage(for: Int)
    func unlikeMessage(for: Int)
}

protocol HomeViewModelOutputProtocol: AnyObject {
    func didUpdateConfessions(with data: [ConfessionData])
    func didFailToLikeMessage(with error: Error)
    func didFailWithError(_ error: Error)
}

final class HomeViewModel {
    weak var delegate: HomeViewModelOutputProtocol?
    var onConfessionsChanged: ((Confession) -> Void)?
    let homeService: HomeServiceProtocol
    var confessions: Confession?
    
    private var currentPage = 1
    private(set) var isLoading = false
    private(set) var hasMoreData = true
    
    init(homeService: HomeServiceProtocol = HomeService()) {
        self.homeService = homeService
    }
    
    func fetchConfessions(reset: Bool = false) {
        if reset {
            currentPage = 1
            hasMoreData = true
            confessions = nil
        }
        fetchConfessions(page: currentPage, limit: 10)
    }
    
    func fetchConfessions(page: Int, limit: Int) {
        guard !isLoading, hasMoreData else { return }
        isLoading = true
//        delegate?.didStartLoading()
        
        homeService.fetchConfessions(page: page, limit: limit) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
//            self.delegate?.didFinishLoading()
            
            switch result {
            case .success(let newConfessions):
                if self.confessions == nil {
                    self.confessions = newConfessions
                } else {
                    self.confessions?.data.append(contentsOf: newConfessions.data)
                }
                
                if page >= newConfessions.totalPages {
                    self.hasMoreData = false
                } else {
                    self.currentPage += 1
                }
                
                self.delegate?.didUpdateConfessions(with: confessions?.data ?? [])

            case .failure(let error):
                self.delegate?.didFailWithError(error)
                print("Error fetching confessions: \(error)")
            }
        }
    }
    func likeMessage(for confessionId: Int) {
        toggleLike(for: confessionId)
        DispatchQueue.main.async {
            self.homeService.likeConfessions(messageId: confessionId) { [weak self] result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    self?.toggleLike(for: confessionId)
                    self?.delegate?.didFailToLikeMessage(with: error)
                    print("Error liking message: \(error)")
                }
            }
        }
    }
    
    func unlikeMessage(for confessionId: Int) {
        toggleLike(for: confessionId)
        DispatchQueue.main.async {
            self.homeService.unlikeConfessions(messageId: confessionId) { [weak self] result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    self?.toggleLike(for: confessionId)
                    self?.delegate?.didFailToLikeMessage(with: error)
                    print("Error unliking message: \(error)")
                }
            }
        }
    }
    
    private func toggleLike(for confessionId: Int) {
        guard let index = self.confessions?.data.firstIndex(where: { $0.id == confessionId }) else {
            return
        }
        self.confessions?.data[index].liked.toggle()
        
        if self.confessions?.data[index].liked == true {
            self.confessions?.data[index].likeCount += 1
        } else {
            self.confessions?.data[index].likeCount -= 1
        }
        
        if let updatedData = self.confessions?.data {
            delegate?.didUpdateConfessions(with: updatedData)
        }
    }
    
}

extension HomeViewModel: HomeViewModelProtocol { }
