//
//  ChannelManager.swift
//  itirafApp
//
//  Created by Emre on 7.10.2025.
//

import Foundation

final class ChannelManager {
    static let shared = ChannelManager()
    
    private init() {
        self.currentChannel = loadFromDefaults()
    }
    
    private(set) var currentChannel: ChannelData?
    
    
    func getChannel() -> ChannelData? {
        return currentChannel
    }

    
    func getChannelName() -> String? {
        return currentChannel?.title
    }
    
    func getChannelId() -> Int? {
        return currentChannel?.id
    }
    
    func setChannel(_ channel: ChannelData) {
        self.currentChannel = channel
        saveToDefaults(channel)
        NotificationCenter.default.post(name: .channelDidChange, object: nil)
    }
    
    private func loadChannel() {
        if let saved = loadFromDefaults() {
            self.currentChannel = saved
        }
    }
    
    func clear() {
        currentChannel = nil
        UserDefaults.standard.removeObject(forKey: .currentChannel)
    }
    
    private func saveToDefaults(_ channel: ChannelData) {
        if let data = try? JSONEncoder().encode(channel) {
            UserDefaults.standard.set(data, forKey: .currentChannel)
        }
    }
    
    private func loadFromDefaults() -> ChannelData? {
        guard let data = UserDefaults.standard.data(forKey: .currentChannel),
              let channel = try? JSONDecoder().decode(ChannelData.self, from: data) else {
            return nil
        }
        return channel
    }
}
