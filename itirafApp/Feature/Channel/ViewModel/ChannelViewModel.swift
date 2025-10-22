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
    func selectChannel(at index: Int)
    func cancelSearch()
}

protocol ChannelViewModelOutputProtocol: AnyObject {
    func didUpdateChannel()
    func didFailWithError(_ error: Error)
    func didStartLoading()
    func didFinishLoading()
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
        delegate?.didStartLoading()
        defer {
            isLoading = false
            delegate?.didFinishLoading()
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
        delegate?.didStartLoading()
        defer {
            delegate?.didFinishLoading()
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
    
    func selectChannel(at index: Int) {
        let selectedChannel = filterChannels[index]
        ChannelManager.shared.setChannel(selectedChannel)
    }
}
extension ChannelViewModel: @preconcurrency ChannelViewModelProtocol { }

