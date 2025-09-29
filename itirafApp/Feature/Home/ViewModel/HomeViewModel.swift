//
//  HomeViewModel.swift
//  itirafApp
//
//  Created by Emre on 16.09.2025.
//

protocol HomeViewModelProtocol {
    var delegate: HomeViewModelOutputProtocol? { get set }
    var confessions: [Confession] { get set }
    func fetchConfessions()
}

protocol HomeViewModelOutputProtocol: AnyObject {
    func didUpdateConfessions()
    
}

final class HomeViewModel {
    weak var delegate: HomeViewModelOutputProtocol?
    var confessions: [Confession] = [
        Confession(id: "1", text: "This is the first confession. This is the first confession. This is the first confession.", likes: 10, comments: 2),
        Confession(id: "2", text: "This is the second confession.", likes: 5, comments: 1),
        Confession(id: "3", text: "This is the third confession.", likes: 8, comments: 3),
        Confession(id: "3", text: "This is the third confession.", likes: 8, comments: 3),
        Confession(id: "3", text: "This is the third confession.", likes: 8, comments: 3),
        Confession(id: "3", text: "This is the third confession.", likes: 8, comments: 3),
        Confession(id: "3", text: "This is the third confession.", likes: 8, comments: 3),
        Confession(id: "3", text: "This is the third confession.", likes: 8, comments: 3),
        Confession(id: "3", text: "This is the third confession.", likes: 8, comments: 3),
        
    ]
    
    func fetchConfessions() {
        delegate?.didUpdateConfessions()
    }
}

extension HomeViewModel: HomeViewModelProtocol { }
