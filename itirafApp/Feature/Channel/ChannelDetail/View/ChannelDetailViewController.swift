//
//  ChannelDetailViewController.swift
//  itirafApp
//
//  Created by Emre on 13.11.2025.
//

import UIKit

final class ChannelDetailViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataSource: UICollectionViewDiffableDataSource<Section, ConfessionData>!
    var viewModel: ChannelDetailViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        loadCollectionView()
        configureDataSource()
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
        navigationItem.title = viewModel.channel.title.capitalized
        let messageImage = UIImage(systemName: "plus.bubble")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: messageImage, style: .plain, target: self, action: #selector(messageButtonTapped))
        
        Task {
            await viewModel.fetchConfessions(reset: true)
        }
    }
    
    private func loadCollectionView() {
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "ConfessionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "confessionCell")
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = UICollectionViewFlowLayout.automaticSize
            
            flowLayout.estimatedItemSize = CGSize(width: collectionView.frame.width, height: 100)
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshConfession), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, ConfessionData>(collectionView: collectionView) { (collectionView, indexPath, confession) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "confessionCell", for: indexPath) as? ConfessionCollectionViewCell else {
                fatalError("Cannot create new cell")
            }
            cell.configure(with: confession)
            
            cell.onLikeButtonTapped = { [weak self] in
                guard let self = self else { return }
                
                Task {
                    await self.viewModel.toggleLikeStatus(for: confession.id)
                }
            }
            
            return cell
        }
        dataSource.supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) -> UICollectionReusableView? in
            
            guard kind == UICollectionView.elementKindSectionHeader else {
                return nil
            }
            
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "HeaderView",
                for: indexPath) as? ChannelHeaderView else {
                fatalError("Cannot create header view")
            }
            
            guard let channelInfo = self?.viewModel.channel else { return nil }
            guard let isFollowed = self?.viewModel.isChannelFollowed(channelId: channelInfo.id) else { return nil }
            
            header.configurationView(channel: channelInfo, isFollowed: isFollowed)
            
            header.onSubButtonTapped = { [weak self] in
                guard let self = self else { return }
                Task(priority: .utility) {
                    if isFollowed {
                        await self.viewModel.unfollowCurrentChannel()
                    } else {
                        await self.viewModel.followCurrentChannel()
                    }
                }
            }
            return header
        }
    }
    
    private func updateSnapshot(with confessions: [ConfessionData]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ConfessionData>()
        snapshot.appendSections([.main])
        snapshot.appendItems(confessions, toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    @objc private func refreshConfession() {
        Task {
            await viewModel.fetchConfessions(reset: true)
        }
    }
    
    @objc private func messageButtonTapped() {
        let selectionVC: PostConfessionViewController = Storyboard.main.instantiate(.postConfession)
        selectionVC.postConfessionViewModel = PostConfessionViewModel(selectedChannel: viewModel.channel)
        
        let navController = UINavigationController(rootViewController: selectionVC)
        
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        
        present(navController, animated: true)
    }
}

extension ChannelDetailViewController: ChannelDetailViewModelDelegate {
    func didUpdateConfessions(with data: [ConfessionData]) {
        DispatchQueue.main.async {
            self.updateSnapshot(with: data)
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    func didUpdateFollowStatus() {
        DispatchQueue.main.async {
            var currentSnapshot = self.dataSource.snapshot()
            currentSnapshot.reloadSections(currentSnapshot.sectionIdentifiers)
            self.dataSource.apply(currentSnapshot, animatingDifferences: false)
        }
    }
    
    func didFailToLikeMessage(with error: Error) {
        print("Failed to like message: \(error)")
    }
    
    func didFailWithError(_ error: Error) {
        print("Error: \(error)")
        DispatchQueue.main.async {
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
}
