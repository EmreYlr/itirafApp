//
//  HomeViewModel.swift
//  itirafApp
//
//  Created by Emre on 16.09.2025.
//

protocol HomeViewModelProtocol {
    var delegate: HomeViewModelOutputProtocol? { get set }
    var confessions: Confession? { get set }
//    var onConfessionsChanged: ((Confession) -> Void)? { get set }
    func fetchConfessions(reset: Bool)
    func toggleLike(at index: Int)
    func addComment(to index: Int)
}

protocol HomeViewModelOutputProtocol: AnyObject {
    func didUpdateConfessions()
    func didFailWithError(_ error: Error)
}

final class HomeViewModel {
    weak var delegate: HomeViewModelOutputProtocol?
    var onConfessionsChanged: ((Confession) -> Void)?
    let homeService: HomeServiceProtocol
    var confessions: Confession?
    
    private var currentPage = 1
    private var isLoading = false
    private var hasMoreData = true
    
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
                
                self.delegate?.didUpdateConfessions()

            case .failure(let error):
                self.delegate?.didFailWithError(error)
                print("Error fetching confessions: \(error)")
            }
        }
    }
    
    
//    var confessions: Confession? { didSet {
//        onConfessionsChanged?(confessions)
//        }
//    }
    
    
    func toggleLike(at index: Int) {
//        self.confessions[index].isLiked.toggle()
//        self.confessions[index].likeCount += self.confessions[index].isLiked ? 1 : -1
//        homeService.likeConfessions(confession: confessions[index]) { result in
//            switch result {
//            case .success(let updatedConfessions):
//                self.confessions[index].isLiked.toggle()
//                self.confessions[index].likes += self.confessions[index].isLiked ? 1 : -1
//                self.confessions = updatedConfessions
//            case .failure(let error):
//                print("Error liking confession: \(error)")
//            }
//        }
    }
    
    func addComment(to index: Int) {
        //confessions[index].comments += 1
    }
    
}

extension HomeViewModel: HomeViewModelProtocol { }
