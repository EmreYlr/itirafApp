//
//  ChannelViewController+SearchBar.swift
//  itirafApp
//
//  Created by Emre on 8.10.2025.
//
import UIKit

extension ChannelViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            channelViewModel.cancelSearch()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        channelViewModel.cancelSearch()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text, !keyword.isEmpty else { return }
        
        searchBar.resignFirstResponder()
        searchBar.isUserInteractionEnabled = false
        
        Task {
            defer {
                searchBar.isUserInteractionEnabled = true
            }
            await channelViewModel.searchChannels(keyword: keyword)
        }
    }
    
}
