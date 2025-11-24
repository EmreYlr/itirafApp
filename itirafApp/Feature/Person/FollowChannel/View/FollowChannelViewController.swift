//
//  FollowChannelViewController.swift
//  itirafApp
//
//  Created by Emre on 15.11.2025.
//

import UIKit

final class FollowChannelViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var viewModel: FollowChannelViewModel
    
    required init?(coder: NSCoder) {
        self.viewModel = FollowChannelViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        initCollectionView()
        initSearchBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    private func initData() {
        viewModel.delegate = self
        navigationItem.title = "channel.title.followed_channels".localized
        Task {
            await viewModel.getFollowedChannels()
            
        }
    }
    
    private func initCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: "ChannelCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "channelCell")
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshChannels), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func initSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "channel.search.placeholder".localized
        searchBar.showsCancelButton = true
    }
    
    
    @objc private func refreshChannels() {
        Task {
            await viewModel.getFollowedChannels()
        }
    }
}

extension FollowChannelViewController: FollowChannelViewModelDelegate {
    func didUpdateFollowedChannels() {
        DispatchQueue.main.async {
            self.collectionView.refreshControl?.endRefreshing()
            self.collectionView.reloadData()
        }
    }
    
    func didFailWithError(_ error: any Error) {
        DispatchQueue.main.async {
            self.collectionView.refreshControl?.endRefreshing()
            self.handleError(error)
        }
    }
}
