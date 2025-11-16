//
//  ChannelViewController.swift
//  itirafApp
//
//  Created by Emre on 7.10.2025.
//

import UIKit

final class ChannelViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var channelViewModel: ChannelViewModelProtocol
    let refreshControl = UIRefreshControl()
    
    required init(coder: NSCoder) {
        self.channelViewModel = ChannelViewModel()
        super.init(coder: coder)!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("ChannelViewController")
        initData()
        initCollectionView()
        initSearchBar()
    }
    
    private func initData() {
        channelViewModel.delegate = self
        Task {
            await channelViewModel.fetchChannel(reset: true)
        }
    }
    
    private func initCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: "ChannelCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "channelCell")
                
        refreshControl.addTarget(self, action: #selector(refreshChannels), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func initSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Kanal ara..."
        searchBar.showsCancelButton = true
    }
    
    @objc private func refreshChannels() {
        guard !channelViewModel.isSearching else {
            self.refreshControl.endRefreshing()
            return
        }
        
        Task {
            await channelViewModel.fetchChannel(reset: true)
        }
    }

}

extension ChannelViewController: ChannelViewModelOutputProtocol {
    func didUpdateChannel() {
        DispatchQueue.main.async {
            self.collectionView.refreshControl?.endRefreshing()
            self.collectionView.reloadData()
        }
    }
    
    func didFailWithError(_ error: any Error) {
        print(error.localizedDescription)
    }
}

