//
//  PostConfessionViewModel.swift
//  itirafApp
//
//  Created by Emre on 15.10.2025.
//

protocol PostConfessionViewModelProtocol {
    var delegate: PostConfessionViewModelOutputProtocol? { get set }
    func postConfession(content: PostConfession) async
}

protocol PostConfessionViewModelOutputProtocol: AnyObject {
    func didPostConfessionSuccessfully()
    func didFailToPostConfession(with error: Error)
}

@MainActor
final class PostConfessionViewModel {
    weak var delegate: PostConfessionViewModelOutputProtocol?
    
    private let postConfessionService: PostConfessionServiceProtocol
    
    init(postConfessionService: PostConfessionServiceProtocol = PostConfessionService()) {
        self.postConfessionService = postConfessionService
    }
    
    func postConfession(content: PostConfession) async {
        do {
            try await postConfessionService.postConfession(content: content)
            delegate?.didPostConfessionSuccessfully()
        } catch {
            delegate?.didFailToPostConfession(with: error)
        }
    }
    
}

extension PostConfessionViewModel: @preconcurrency PostConfessionViewModelProtocol { }
