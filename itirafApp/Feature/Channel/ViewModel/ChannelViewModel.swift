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
    func fetchChannel()
    func selectChannel(at index: Int)
}

protocol ChannelViewModelOutputProtocol: AnyObject {
    func didUpdateChannel()
    func didFailWithError(_ error: Error)
}

final class ChannelViewModel {
    weak var delegate: ChannelViewModelOutputProtocol?
    var channel: Channel?
    
    private let channelService: ChannelServiceProtocol
    
    init(channelService: ChannelServiceProtocol = ChannelService()) {
        self.channelService = channelService
    }
    
    func fetchChannel() {
        fetchChannel(page: 1, pageSize: 10)
    }
    
    func fetchChannel(page: Int = 1, pageSize: Int = 10)  {
        channelService.fetchChannels(page: page, pageSize: pageSize) { result in
            switch result {
            case .success(let channel):
                self.channel = channel
                self.delegate?.didUpdateChannel()
            case .failure(let error):
                self.delegate?.didFailWithError(error)
                print("Error fetching channels: \(error)")
            }
        }
    }
    
    func selectChannel(at index: Int){
        guard let channel = channel, index < channel.data.count else {
            return
        }
        let selectedChannel = channel.data[index]
        ChannelManager.shared.setChannel(selectedChannel)
    }
}

extension ChannelViewModel: ChannelViewModelProtocol { }

