//
//  PostConfessionViewModel.swift
//  itirafApp
//
//  Created by Emre on 15.10.2025.
//

protocol PostConfessionViewModelProtocol {
    var delegate: PostConfessionViewModelOutputProtocol? { get set }
    var selectedChannel: ChannelData? { get set }
    func postConfession(content: PostConfession) async
    func isChannelEmpty() -> Bool
    func getContentCharrecterCount() -> Int
    func getTitleCharrecterCount() -> Int
}

protocol PostConfessionViewModelOutputProtocol: AnyObject {
    func didPostConfessionSuccessfully()
    func didFailToPostConfession(with error: Error)
}

final class PostConfessionViewModel {
    weak var delegate: PostConfessionViewModelOutputProtocol?
    var selectedChannel: ChannelData?
    private let maxContentCharacterCount = 500
    private let maxTitleCharacterCount = 100
    
    private let postConfessionService: PostConfessionServiceProtocol
    
    init(postConfessionService: PostConfessionServiceProtocol = PostConfessionService()) {
        self.postConfessionService = postConfessionService
    }
    
    init(selectedChannel: ChannelData, postConfessionService: PostConfessionServiceProtocol = PostConfessionService()) {
        self.postConfessionService = postConfessionService
        self.selectedChannel = selectedChannel
    }
    
    func postConfession(content: PostConfession) async {
        do {
            try await postConfessionService.postConfession(content: content)
            selectedChannel = nil
            delegate?.didPostConfessionSuccessfully()
        } catch {
            delegate?.didFailToPostConfession(with: error)
        }
    }
    
    func isChannelEmpty() -> Bool {
        return FollowManager.shared.isChannelEmpty()
    }
    
    func getContentCharrecterCount() -> Int {
        return maxContentCharacterCount
    }
    
    func getTitleCharrecterCount() -> Int {
        return maxTitleCharacterCount
    }
    
}

extension PostConfessionViewModel: PostConfessionViewModelProtocol { }
