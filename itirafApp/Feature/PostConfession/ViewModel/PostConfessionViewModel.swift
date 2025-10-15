//
//  PostConfessionViewModel.swift
//  itirafApp
//
//  Created by Emre on 15.10.2025.
//

protocol PostConfessionViewModelProtocol {
    var delegate: PostConfessionViewModelOutputProtocol? { get set }
    func postConfession(content: PostConfession)
}

protocol PostConfessionViewModelOutputProtocol: AnyObject {
    func didPostConfessionSuccessfully()
    func didFailToPostConfession(with error: Error)
}

final class PostConfessionViewModel {
    weak var delegate: PostConfessionViewModelOutputProtocol?
    
    private let postConfessionService: PostConfessionServiceProtocol
    
    init(postConfessionService: PostConfessionServiceProtocol = PostConfessionService()) {
        self.postConfessionService = postConfessionService
    }
    
    func postConfession(content: PostConfession) {
        postConfessionService.postConfession(content: content) { [weak self] result in
            switch result {
            case .success:
                self?.delegate?.didPostConfessionSuccessfully()
            case .failure(let error):
                self?.delegate?.didFailToPostConfession(with: error)
            }
        }
    }
    
}

extension PostConfessionViewModel: PostConfessionViewModelProtocol { }
