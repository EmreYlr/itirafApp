//
//  ChannelViewController+TableView.swift
//  itirafApp
//
//  Created by Emre on 7.10.2025.
//

import UIKit

extension ChannelViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let channelCount = channelViewModel.filterChannels.count
        return channelCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //TODO: - ReuseIdentifier ekle ve custom cell yap
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let channel = channelViewModel.filterChannels[indexPath.row]
        cell.textLabel?.text = channel.title
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        channelViewModel.selectChannel(at: indexPath.row)
        searchBar.text = ""
        channelViewModel.cancelSearch()
        tabBarController?.selectedIndex = 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !channelViewModel.isSearching else { return }

        if indexPath.row == (channelViewModel.channel?.data.count ?? 0) - 1 {
            Task {
                await channelViewModel.fetchChannel(reset: false)
            }
        }
    }
}
