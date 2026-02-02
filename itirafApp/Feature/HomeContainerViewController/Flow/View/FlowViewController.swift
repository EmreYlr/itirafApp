//
//  FlowViewController.swift
//  itirafApp
//
//  Created by Emre on 13.11.2025.
//

import UIKit
import SkeletonView

final class FlowViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewModel: FlowViewModelProtocol
    var dataSource: FlowDiffableDataSource!
    private var revealedNsfwItems = Set<Int>()
    
    required init?(coder: NSCoder) {
        self.viewModel = FlowViewModel()
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
        ClarityManager.shared.setCurrentScreen(name: "Flow")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.sendPendingSeenMessages()
    }
    
    private func initView() {
        viewModel.delegate = self
        Task {
            await viewModel.fetchFlow(reset: true)
        }
    }
    
    private func loadCollectionView() {
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "ConfessionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "confessionCell")
        
        collectionView.collectionViewLayout = .createFullWidthDynamicLayout(spacing: 10, contentInsets: NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0), estimatedHeight: 100)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshFlow), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        collectionView.isSkeletonable = true
    }
    
    private func configureDataSource() {
        dataSource = FlowDiffableDataSource(collectionView: collectionView) { (collectionView, indexPath, flow) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "confessionCell", for: indexPath) as? ConfessionCollectionViewCell else {
                fatalError("Cannot create new cell")
            }
            let isRevealed = self.revealedNsfwItems.contains(flow.id)
            
            cell.configure(with: flow, isRevealed: isRevealed)
            
            cell.onNsfwRevealed = { [weak self] in
                self?.revealedNsfwItems.insert(flow.id)
            }
            
            cell.onLikeButtonTapped = { [weak self, weak cell] in
                guard let self = self, let cell = cell else { return }
                let isLikedNow = flow.liked
                let futureState = !isLikedNow

                let currentCount = flow.likeCount
                let futureCount = isLikedNow ? (currentCount - 1) : (currentCount + 1)

                cell.updateLikeButton(isLiked: futureState, animated: true)
                cell.updateLikeCount(newCount: futureCount, animated: true)
                
                Task {
                    await self.viewModel.toggleLikeStatus(for: flow.id)
                }
            }
            
            cell.onCommentButtonTapped = { [weak self] in
                guard let self = self else { return }
                
                let detailVC = Storyboard.main.instantiate(.detail) as! DetailViewController
                detailVC.detailViewModel = DetailViewModel(messageId: flow.id)
                navigationController?.pushViewController(detailVC, animated: true)
            }
            
            
            cell.onShareButtonTapped = { [weak self] in
                Task {
                    await self?.viewModel.createShortlink(for: flow.id)
                }
            }
            
            cell.onDMButtonTapped = { [weak self] in
                self?.handleDMButtonAction(messageId: flow.id)
            }
            
            cell.onChannelTapped = { [weak self] in
                guard let self = self else { return }
                let channelDetailVC: ChannelDetailViewController = Storyboard.channelDetail.instantiate(.channelDetail)
                channelDetailVC.viewModel = ChannelDetailViewModel(channel: flow.channel)
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
    
    private func updateSnapshot(with flow: [FlowData]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, FlowData>()
        snapshot.appendSections([.main])
        snapshot.appendItems(flow, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func scrollToTop() {
        guard collectionView.numberOfSections > 0, collectionView.numberOfItems(inSection: 0) > 0 else { return }
        
        collectionView.setContentOffset(CGPoint(x: 0, y: -collectionView.adjustedContentInset.top), animated: true)
    }
    
    @objc private func refreshFlow() {
        Task {
            defer {
                self.collectionView.refreshControl?.endRefreshing()
            }
            await viewModel.fetchFlow(reset: true)
        }
    }
    
}

extension FlowViewController: FlowViewModelDelegate {
    func didUpdateFlow(with data: [FlowData]) {
        DispatchQueue.main.async {
            if self.collectionView.sk.isSkeletonActive {
                self.collectionView.stopSkeletonAnimation()
                self.view.hideSkeleton()
            }
            
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
    
    func didFailToLikeMessage(with error: Error) {
        print("Failed to like message: \(error)")
    }
    
    func didFailWithError(_ error: Error) {
        print("Error: \(error)")
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
