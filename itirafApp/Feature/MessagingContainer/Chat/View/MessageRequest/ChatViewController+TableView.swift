//
//  ChatViewController+TableView.swift
//  itirafApp
//
//  Created by Emre on 1.11.2025.
//

import UIKit

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        let count = viewModel.requestMessage?.requesterSocialLinks?.count ?? 0
        return count == 0 ? 1 : count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "socialCell", for: indexPath) as? SocialLinkTableViewCell else {
            return UITableViewCell()
        }
        
        let links = viewModel.requestMessage?.requesterSocialLinks
        
        if links?.isEmpty ?? true {
            cell.configureForAnonymous()
            cell.selectionStyle = .none
        }
        else if let link = links?[indexPath.section] {
            cell.configure(with: link)
            cell.selectionStyle = .default
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let links = viewModel.requestMessage?.requesterSocialLinks
        
        if links?.isEmpty ?? true {
            return
        }
        
        if let selectedLink = viewModel.requestMessage?.requesterSocialLinks?[indexPath.section] {
            if let url = URL(string: selectedLink.url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? CGFloat.leastNormalMagnitude : 5.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
}
