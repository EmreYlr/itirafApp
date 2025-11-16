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
    var filterChannels: [ChannelData] { set get }
    var isSearching: Bool { get set }
    func fetchChannel(reset: Bool) async
    func searchChannels(keyword: String) async
    func cancelSearch()
    func followChannel(at index: Int) async
    func unfollowChannel(at index: Int) async
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
    
    var filterChannels: [ChannelData] = []
    var isSearching = false
    
    private var currentPage = 1
    private var isLoading = false
    private var hasMoreData = true
    
    private let channelService: ChannelServiceProtocol
    private let followManager: FollowManager
    
    init(channelService: ChannelServiceProtocol = ChannelService(), followManager: FollowManager = FollowManager.shared) {
        self.channelService = channelService
        self.followManager = followManager
    }
    
    func fetchChannel(reset: Bool = false) async {
        if reset {
            currentPage = 1
            hasMoreData = true
        }
        
        guard !isLoading, hasMoreData else { return }
        
        isLoading = true
        defer {
            isLoading = false
        }
        
        do {
            let newChannel = try await channelService.fetchChannels(page: currentPage, pageSize: 10)
            
            if reset {
                self.channel = newChannel
                if !isSearching {
                    self.filterChannels = self.channel?.data ?? []
                }
            } else {
                self.channel?.data.append(contentsOf: newChannel.data)
                if !isSearching {
                    self.filterChannels = self.channel?.data ?? []
                }
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
            //delegate?.didFinishLoading()
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

        do {
            try await followManager.followChannel(channel: channelToFollow)
            delegate?.didUpdateChannel()
        } catch {
            delegate?.didFailWithError(error)
        }
    }
    
    func unfollowChannel(at index: Int) async {
        let channelToFollow = filterChannels[index]
        do {
            try await followManager.unfollowChannel(channel: channelToFollow)
            delegate?.didUpdateChannel()
        } catch {
            delegate?.didFailWithError(error)
        }
    }
    
    func isChannelFollowed(channelId: Int) -> Bool {
        return followManager.isChannelFollowed(channelId: channelId)
    }
    
}
extension ChannelViewModel: @preconcurrency ChannelViewModelProtocol { }

