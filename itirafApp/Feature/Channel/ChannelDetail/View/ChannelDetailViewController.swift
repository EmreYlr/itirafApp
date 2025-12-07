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
    private var revealedNsfwItems = Set<Int>()
    
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
        
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.isChannelFollowed()
        
        Task {
            await viewModel.fetchConfessions(reset: true)
        }
    }
    
    private func loadCollectionView() {
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "ConfessionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "confessionCell")
        collectionView.register(UINib(nibName: "ChannelDetailHeaderCollectionViewCell", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "channelHeaderCell")
        
        collectionView.collectionViewLayout = .createFullWidthDynamicLayout(
            spacing: 10,
            contentInsets: NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0),
            estimatedHeight: 100,
            headerHeight: 250
        )
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshConfession), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, ConfessionData>(collectionView: collectionView) { (collectionView, indexPath, confession) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "confessionCell", for: indexPath) as? ConfessionCollectionViewCell else {
                fatalError("Cannot create new cell")
            }
            let isRevealed = self.revealedNsfwItems.contains(confession.id)
            
            cell.configure(with: confession, isRevealed: isRevealed)
            
            cell.onNsfwRevealed = { [weak self] in
                self?.revealedNsfwItems.insert(confession.id)
            }
            
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
                withReuseIdentifier: "channelHeaderCell",
                for: indexPath) as? ChannelDetailHeaderCollectionViewCell else {
                fatalError("Cannot create header view")
            }
            
            guard let self = self else { return nil }
            let channelInfo = self.viewModel.channel
            let isFollowed = self.viewModel.isChannelFollowed()
            
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
        let selectionVC: PostConfessionViewController = Storyboard.post.instantiate(.postConfession)
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
            if !currentSnapshot.sectionIdentifiers.isEmpty {
                currentSnapshot.reloadSections([.main])
                self.dataSource.apply(currentSnapshot, animatingDifferences: false)
            }
            self.navigationItem.rightBarButtonItem?.isEnabled = self.viewModel.isChannelFollowed()
        }
    }
    
    func didFailToLikeMessage(with error: Error) {
        print("Failed to like message: \(error)")
    }
    
    func didFailWithError(_ error: Error) {
        DispatchQueue.main.async {
            self.collectionView.refreshControl?.endRefreshing()
            self.handleError(error)
        }
    }
}
