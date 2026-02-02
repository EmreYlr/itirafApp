//
//  ViewController.swift
//  itirafApp
//
//  Created by Emre on 12.09.2025.
//

import UIKit
import SkeletonView

final class HomeViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var collectionView: UICollectionView!
    
    var homeViewModel: HomeViewModelProtocol
    let refreshControl = UIRefreshControl()
    var dataSource: HomeDiffableDataSource!
    private var revealedNsfwItems = Set<Int>()

    required init?(coder: NSCoder) {
        self.homeViewModel = HomeViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        loadCollectionView()
        configureDataSource()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ClarityManager.shared.setCurrentScreen(name: "Home")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        homeViewModel.sendPendingSeenMessages()
    }
    
    private func loadCollectionView() {
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "ConfessionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "confessionCell")
        
        collectionView.collectionViewLayout = .createFullWidthDynamicLayout(spacing: 10, contentInsets: NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0), estimatedHeight: 100)
        
        refreshControl.addTarget(self, action: #selector(refreshConfession), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        collectionView.isSkeletonable = true
    }
    
    private func initView() {
        homeViewModel.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateChannel), name: .channelDidChange, object: nil)
        Task {
            await homeViewModel.fetchConfessions(reset: true)
        }
    }
    
    private func configureDataSource() {
        dataSource = HomeDiffableDataSource(collectionView: collectionView) { (collectionView, indexPath, confession) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "confessionCell", for: indexPath) as? ConfessionCollectionViewCell else {
                fatalError("Cannot create new cell")
            }
            
            let isRevealed = self.revealedNsfwItems.contains(confession.id)
            
            cell.configure(with: confession, isRevealed: isRevealed)
            
            cell.onNsfwRevealed = { [weak self] in
                self?.revealedNsfwItems.insert(confession.id)
            }
            
            cell.onLikeButtonTapped = { [weak self, weak cell] in
                guard let self = self, let cell = cell else { return }
                let isLikedNow = confession.liked
                let futureState = !(confession.liked)

                let currentCount = confession.likeCount
                let futureCount = isLikedNow ? (currentCount - 1) : (currentCount + 1)
                
                cell.updateLikeButton(isLiked: futureState, animated: true)
                cell.updateLikeCount(newCount: futureCount, animated: true)

                Task {
                    await self.homeViewModel.toggleLikeStatus(for: confession.id)
                }
            }
            
            cell.onCommentButtonTapped = { [weak self] in
                guard let self = self else { return }
                
                let detailVC = Storyboard.main.instantiate(.detail) as! DetailViewController
                detailVC.detailViewModel = DetailViewModel(messageId: confession.id)
                navigationController?.pushViewController(detailVC, animated: true)
            }
            
            
            cell.onShareButtonTapped = { [weak self] in
                Task {
                    await self?.homeViewModel.createShortlink(for: confession.id)
                }
            }
            
            cell.onDMButtonTapped = { [weak self] in
                self?.handleDMButtonAction(messageId: confession.id)
            }
            
            guard let channel = confession.channel else {
                return cell
            }
            
            cell.onChannelTapped = { [weak self] in
                guard let self = self else { return }
                let channelDetailVC: ChannelDetailViewController = Storyboard.channelDetail.instantiate(.channelDetail)
                channelDetailVC.viewModel = ChannelDetailViewModel(channel: channel)
                navigationController?.pushViewController(channelDetailVC, animated: true)
            }
            
            return cell
        }
        collectionView.showAnimatedGradientSkeleton()

    }

    private func handleDMButtonAction(messageId: Int) {
        let requestBottomSheetVC: RequestBottomSheetViewController = Storyboard.requestBottomSheet.instantiate(.requestBottomSheet)
        
        let viewModel = RequestBottomSheetViewModel(channelMessageId: messageId)
        requestBottomSheetVC.viewModel = viewModel
        
        if let sheet = requestBottomSheetVC.sheetPresentationController {
            let customDetent = UISheetPresentationController.Detent.custom(identifier: .init("customDetent")) { context in
                return context.maximumDetentValue * 0.7
            }
            sheet.detents = [customDetent, .large()]
            
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }
        
        self.present(requestBottomSheetVC, animated: true)
    }
    
    private func updateSnapshot(with confessions: [ConfessionData]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ConfessionData>()
        snapshot.appendSections([.main])
        snapshot.appendItems(confessions, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func scrollToTop() {
        guard collectionView.numberOfSections > 0, collectionView.numberOfItems(inSection: 0) > 0 else { return }
        
        collectionView.setContentOffset(CGPoint(x: 0, y: -collectionView.adjustedContentInset.top), animated: true)
    }
    
    @objc private func updateChannel() {
        refreshConfession()
    }
    
    @objc private func refreshConfession() {
        Task {
            defer {
                self.refreshControl.endRefreshing()
            }
            await homeViewModel.fetchConfessions(reset: true)
        }
    }
}

extension HomeViewController: HomeViewModelOutputProtocol, EmptyStateDisplayable {
    func didUpdateConfessions(with data: [ConfessionData]) {
        DispatchQueue.main.async {
            self.stopSkeletonLoading()
            self.hideEmptyState(from: self.collectionView)
            self.updateSnapshot(with: data)
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    func didCreateShortlink(shortlink: String) {
        let activityViewController = UIActivityViewController(activityItems: [shortlink], applicationActivities: nil)
        DispatchQueue.main.async {
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func didFailToCreateShortlink(with error: any Error) {
        DispatchQueue.main.async {
            self.handleError(error)
        }
    }
    
    func didEmptyConfessions() {
        DispatchQueue.main.async {
            self.stopSkeletonLoading()
            self.updateSnapshot(with: [])
            self.showEmptyState(type: .noFollowingChannels, in: self.collectionView, action: {
                self.tabBarController?.selectedIndex = 1
            })
        }
    }
    
    func didFailToLikeMessage(with error: Error) {
        print("Failed to like message: \(error)")
    }
    
    func didFailWithError(_ error: Error) {
        DispatchQueue.main.async {
            self.stopSkeletonLoading()
            self.hideEmptyState(from: self.collectionView)
            self.collectionView.refreshControl?.endRefreshing()
            self.handleError(error)
        }
    }
    
    private func stopSkeletonLoading() {
        if self.collectionView.sk.isSkeletonActive {
            self.collectionView.stopSkeletonAnimation()
            self.view.hideSkeleton()
        }
    }
}
