//
//  FollowChannelViewController+SerachBar.swift
//  itirafApp
//
//  Created by Emre on 15.11.2025.
//

import UIKit

extension FollowChannelViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            viewModel.cancelSearch()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        viewModel.cancelSearch()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text, !keyword.isEmpty else { return }
        
        searchBar.resignFirstResponder()
        searchBar.isUserInteractionEnabled = false
        
        Task {
            defer {
                searchBar.isUserInteractionEnabled = true
            }
            await viewModel.searchChannels(keyword: keyword)
        }
    }
    
}
