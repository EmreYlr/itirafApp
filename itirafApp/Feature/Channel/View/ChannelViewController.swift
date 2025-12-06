//
//  ChannelViewController.swift
//  itirafApp
//
//  Created by Emre on 7.10.2025.
//

import UIKit
import SkeletonView

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
        initData()
        initCollectionView()
        initSearchBar()
        setupHideKeyboardOnTap()
    }
    
    private func initData() {
        channelViewModel.delegate = self
        Task {
            await channelViewModel.fetchChannel(reset: true)
        }
    }
    
    private func setupHideKeyboardOnTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func initCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: "ChannelCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "channelCell")
        collectionView.isSkeletonable = true
        
        refreshControl.addTarget(self, action: #selector(refreshChannels), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        collectionView.collectionViewLayout = .createFullWidthDynamicLayout(spacing: 15, estimatedHeight: 60)
        
        collectionView.showAnimatedGradientSkeleton()
    }
    
    private func initSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "channel.search.placeholder".localized
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
            if self.collectionView.sk.isSkeletonActive {
                self.collectionView.stopSkeletonAnimation()
                self.view.hideSkeleton()
            }
            
            self.collectionView.refreshControl?.endRefreshing()
            self.collectionView.reloadData()
        }
    }
    
    func didFailWithError(_ error: any Error) {
        DispatchQueue.main.async {
            if self.collectionView.sk.isSkeletonActive {
                self.collectionView.stopSkeletonAnimation()
                self.view.hideSkeleton()
            }
            
            self.collectionView.refreshControl?.endRefreshing()
            self.handleError(error)
        }
    }
}

