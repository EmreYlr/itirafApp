//
//  ChannelViewController+TableView.swift
//  itirafApp
//
//  Created by Emre on 7.10.2025.
//

import UIKit

extension ChannelViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let channelCount = channelViewModel.channel?.data.count ?? 0
        return channelCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let channel = channelViewModel.channel?.data[indexPath.row]
        cell.textLabel?.text = channel?.name
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator 
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}
