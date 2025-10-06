//
//  HomeViewModel.swift
//  itirafApp
//
//  Created by Emre on 16.09.2025.
//

protocol HomeViewModelProtocol {
    var delegate: HomeViewModelOutputProtocol? { get set }
    var confessions: [Confession] { get set }
    var onConfessionsChanged: (([Confession]) -> Void)? { get set }
    func fetchConfessions()
    func toggleLike(at index: Int)
    func addComment(to index: Int)
}

protocol HomeViewModelOutputProtocol: AnyObject {
    func didUpdateConfessions()
    
}

final class HomeViewModel {
    weak var delegate: HomeViewModelOutputProtocol?
    var onConfessionsChanged: (([Confession]) -> Void)?
    let homeService: HomeServiceProtocol
    
    init(homeService: HomeServiceProtocol = HomeService()) {
        self.homeService = homeService
    }
    
    var confessions: [Confession] = [
        Confession(id: "1", title: "First Confession", message: "This is the first confession. This is the first confession. This is the first confession. This is the first confession.", likeCount: 10, channelId: 1, ownerId: "user1", isLiked: false),
        Confession(id: "2", title: "Second Confession", message: "This is the second confession.", likeCount: 5, channelId: 2, ownerId: "user2", isLiked: true),
        Confession(id: "3", title: "Third Confession", message: "This is the third confession.", likeCount: 8, channelId: 1, ownerId: "user3", isLiked: false),
        Confession(id: "1", title: "First Confession", message: "This is the first confession.", likeCount: 10, channelId: 1, ownerId: "user1", isLiked: false),
        Confession(id: "2", title: "Second Confession", message: "This is the second confession.", likeCount: 5, channelId: 2, ownerId: "user2", isLiked: true),
        Confession(id: "3", title: "Third Confession", message: "This is the third confession.", likeCount: 8, channelId: 1, ownerId: "user3", isLiked: false),
        Confession(id: "1", title: "First Confession", message: "This is the first confession.", likeCount: 10, channelId: 1, ownerId: "user1", isLiked: false),
        Confession(id: "2", title: "Second Confession", message: "This is the second confession.", likeCount: 5, channelId: 2, ownerId: "user2", isLiked: true),
        Confession(id: "3", title: "Third Confession", message: "This is the third confession.", likeCount: 8, channelId: 1, ownerId: "user3", isLiked: false),
        
        
    ] { didSet {
        onConfessionsChanged?(confessions)
        }
    }
    
    
    //TODO: -Getuser isteği atıp user bilgilerini al. Ona göre isAnonymous kontrolü yap.
    
    func toggleLike(at index: Int) {
        self.confessions[index].isLiked.toggle()
        self.confessions[index].likeCount += self.confessions[index].isLiked ? 1 : -1
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
    
    func fetchConfessions() {
        self.delegate?.didUpdateConfessions()
//        homeService.fetchConfessions { result in
//            switch result {
//            case .success(let confessions):
//                self.confessions = confessions
//                self.delegate?.didUpdateConfessions()
//            case .failure(let error):
//                print("Error fetching confessions: \(error)")
//            }
//        }
        
    }
}

extension HomeViewModel: HomeViewModelProtocol { }
