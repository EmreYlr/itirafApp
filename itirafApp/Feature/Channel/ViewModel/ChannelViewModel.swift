//
//  ChannelViewModel.swift
//  itirafApp
//
//  Created by Emre on 7.10.2025.
//

import Foundation

protocol ChannelViewModelProtocol {
    var delegate: ChannelViewModelOutputProtocol? { get set }
    var channel: Channel? { get }
    var followedChannels: [ChannelData] { get }
    var filterChannels: [ChannelData] { set get }
    var isSearching: Bool { get set }
    func fetchChannel(reset: Bool) async
    func searchChannels(keyword: String) async
    func cancelSearch()
    func followChannel(at index: Int) async
    func unfollowChannel(at index: Int) async
    func getFollowedChannels() async
    func isChannelFollowed(channelId: Int) -> Bool
}

protocol ChannelViewModelOutputProtocol: AnyObject {
    func didUpdateChannel()
    func didFailWithError(_ error: Error)
}

@MainActor
final class ChannelViewModel {
    weak var delegate: ChannelViewModelOutputProtocol?
    private(set) var channel: Channel?
    private(set) var followedChannels: [ChannelData] = []
    var filterChannels: [ChannelData] = []
    var isSearching = false
    
    private var currentPage = 1
    private var isLoading = false
    private var hasMoreData = true
    
    private let channelService: ChannelServiceProtocol
    
    init(channelService: ChannelServiceProtocol = ChannelService()) {
        self.channelService = channelService
    }
    
    func fetchChannel(reset: Bool = false) async {
        if reset {
            currentPage = 1
            hasMoreData = true
            channel = nil
            filterChannels.removeAll()
        }
        
        guard !isLoading, hasMoreData else { return }
        
        isLoading = true
        defer {
            isLoading = false
        }
        
        do {
            let newChannel = try await channelService.fetchChannels(page: currentPage, pageSize: 10)
            
            if self.channel == nil {
                self.channel = newChannel
            } else {
                self.channel?.data.append(contentsOf: newChannel.data)
            }
            if !isSearching {
                self.filterChannels = self.channel?.data ?? []
            }
            
            hasMoreData = currentPage < newChannel.totalPages
            if hasMoreData { currentPage += 1 }
            
            delegate?.didUpdateChannel()
            
        } catch {
            delegate?.didFailWithError(error)
        }
    }
    
    func searchChannels(keyword: String) async {
        isSearching = true
        defer {
//            delegate?.didFinishLoading()
        }
        
        do {
            let searchResults = try await channelService.searchChannels(query: keyword)
            self.filterChannels = searchResults
            delegate?.didUpdateChannel()
        } catch {
            delegate?.didFailWithError(error)
        }
    }
    
    func cancelSearch() {
        isSearching = false
        filterChannels = channel?.data ?? []
        delegate?.didUpdateChannel()
    }
    
    func followChannel(at index: Int) async {
        let channelToFollow = filterChannels[index]
        let channelId: [Int] = [channelToFollow.id]
        do {
            try await channelService.followChannel(channelId: channelId)

            if !isChannelFollowed(channelId: channelToFollow.id) {
                followedChannels.append(channelToFollow)
            }
        } catch {
            delegate?.didFailWithError(error)
        }
    }
    
    func unfollowChannel(at index: Int) async {
        let channelId: Int = filterChannels[index].id
        do {
            try await channelService.unfollowChannel(channelId: channelId)
            
            followedChannels.removeAll { $0.id == channelId }
        } catch {
            delegate?.didFailWithError(error)
        }
    }
    
    func getFollowedChannels() async {
        do {
            let followedChannels = try await channelService.getFollowedChannels()
            self.followedChannels = followedChannels
        } catch {
            delegate?.didFailWithError(error)
        }
    }
    
    func isChannelFollowed(channelId: Int) -> Bool {
        return followedChannels.contains { $0.id == channelId }
    }
}
extension ChannelViewModel: @preconcurrency ChannelViewModelProtocol { }

