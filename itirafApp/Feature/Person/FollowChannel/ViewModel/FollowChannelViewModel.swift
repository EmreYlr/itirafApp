//
//  FollowChannelViewModel.swift
//  itirafApp
//
//  Created by Emre on 15.11.2025.
//

protocol FollowChannelViewModelProtocol {
    var delegate: FollowChannelViewModelDelegate? { get set }
    var filterFollowedChannels: [ChannelData] { get }
    func getFollowedChannels() async
    func followChannel(at index: Int) async
    func unfollowChannel(at index: Int) async
    func searchChannels(keyword: String) async
    func cancelSearch()
    func isChannelFollowed(channelId: Int) -> Bool
}

protocol FollowChannelViewModelDelegate: AnyObject {
    func didUpdateFollowedChannels()
    func didFailWithError(_ error: Error)
}

final class FollowChannelViewModel {
    weak var delegate: FollowChannelViewModelDelegate?
    private(set) var followedChannels: [ChannelData] = []
    private(set) var filterFollowedChannels: [ChannelData] = []
    
    private let service: FollowChannelServiceProtocol
    
    init(service: FollowChannelServiceProtocol = FollowChannelService()) {
        self.service = service
    }
    
    func getFollowedChannels() async {
        do {
            let channels = try await service.getFollowedChannels()
            self.followedChannels = channels
            self.filterFollowedChannels = channels
            delegate?.didUpdateFollowedChannels()
        } catch {
            delegate?.didFailWithError(error)
        }
    }
    
    func followChannel(at index: Int) async {
        let channelToFollow = filterFollowedChannels[index]
        let channelId: [Int] = [channelToFollow.id]
        do {
            try await service.followChannel(channelId: channelId)
        } catch {
            delegate?.didFailWithError(error)
        }
    }
    
    func unfollowChannel(at index: Int) async {
        let channelId: Int = filterFollowedChannels[index].id
        do {
            try await service.unfollowChannel(channelId: channelId)
        } catch {
            delegate?.didFailWithError(error)
        }
    }
    
    func searchChannels(keyword: String) async {
        let lowercasedKeyword = keyword.lowercased()

        self.filterFollowedChannels = self.followedChannels.filter {

            $0.title.lowercased().contains(lowercasedKeyword)
        }
        delegate?.didUpdateFollowedChannels()
    }
    
    func cancelSearch() {
        filterFollowedChannels = followedChannels
        delegate?.didUpdateFollowedChannels()
    }
    
    func isChannelFollowed(channelId: Int) -> Bool {
        return followedChannels.contains { $0.id == channelId }
    }
}

extension FollowChannelViewModel: FollowChannelViewModelProtocol {}
