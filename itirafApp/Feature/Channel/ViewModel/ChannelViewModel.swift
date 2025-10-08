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
    func fetchChannel(reset: Bool)
    func selectChannel(at index: Int)
    func searchChannels(keyword: String)
    func cancelSearch()
}

protocol ChannelViewModelOutputProtocol: AnyObject {
    func didUpdateChannel()
    func didFailWithError(_ error: Error)
    func didStartLoading()
    func didFinishLoading()
}

final class ChannelViewModel {
    weak var delegate: ChannelViewModelOutputProtocol?
    var channel: Channel?
    var filterChannels : [ChannelData] = []
    
    private var currentPage = 1
    private var isLoading = false
    private var hasMoreData = true
    var isSearching = false
    
    private let channelService: ChannelServiceProtocol
    
    init(channelService: ChannelServiceProtocol = ChannelService()) {
        self.channelService = channelService
    }
    
    func fetchChannel(reset: Bool = false) {
        if reset {
            currentPage = 1
            hasMoreData = true
            channel = nil
            filterChannels = []
        }
        fetchChannel(page: currentPage, pageSize: 10)
    }
    
    private func fetchChannel(page: Int, pageSize: Int) {
        guard !isLoading, hasMoreData else { return }
        isLoading = true
        delegate?.didStartLoading()
        
        channelService.fetchChannels(page: page, pageSize: pageSize) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            self.delegate?.didFinishLoading()
            
            switch result {
            case .success(let newChannel):
                if self.channel == nil {
                    self.channel = newChannel
                    self.filterChannels = newChannel.data
                } else {
                    self.channel?.data.append(contentsOf: newChannel.data)
                    self.filterChannels.append(contentsOf: newChannel.data)
                }
                
                if page >= newChannel.totalPages {
                    self.hasMoreData = false
                } else {
                    self.currentPage += 1
                }
                
                self.delegate?.didUpdateChannel()
                
            case .failure(let error):
                self.delegate?.didFailWithError(error)
            }
        }
    }
    
    func searchChannels(keyword: String) {
        isSearching = true
        delegate?.didStartLoading()
        
        channelService.searchChannels(query: keyword) { [weak self] result in
            guard let self = self else { return }
            self.delegate?.didFinishLoading()
            
            switch result {
            case .success(let channels):
                self.filterChannels = channels
                self.delegate?.didUpdateChannel()
            case .failure(let error):
                self.delegate?.didFailWithError(error)
            }
        }
    }
    
    func cancelSearch() {
        isSearching = false
        filterChannels = channel?.data ?? []
        delegate?.didUpdateChannel()
    }
    
    func selectChannel(at index: Int){
        let channel = filterChannels
        let selectedChannel = channel[index]
        ChannelManager.shared.setChannel(selectedChannel)
    }
}

extension ChannelViewModel: ChannelViewModelProtocol { }

