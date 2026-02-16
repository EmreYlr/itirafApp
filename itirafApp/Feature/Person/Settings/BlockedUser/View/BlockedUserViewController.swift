//
//  BlockedUserViewController.swift
//  itirafApp
//
//  Created by Emre on 16.02.2026.
//

import UIKit

final class BlockedUserViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var blockedUserDesciriptionLabel: UILabel!
    @IBOutlet weak var blockedUserCountLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataSource: UICollectionViewDiffableDataSource<Section, BlockedUser>!
    
    var viewModel: BlockedUserViewModelProtocol
    
    required init?(coder: NSCoder) {
        self.viewModel = BlockedUserViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUi()
        loadCollectionView()
        configureDataSource()
        initData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    
    private func initUi() {
        navigationItem.title = "settings.block_user".localized
        blockedUserDesciriptionLabel.text = "settings.blocked_users_description".localized
    }
    
    private func initData() {
        viewModel.delegate = self
        showLoading(style: .localDimmed)
        Task {
            defer {
                self.hideLoading()
            }
            await viewModel.fetchBlockedUsers()
            updateBlockedUserCount()
        }
    }
    
    private func loadCollectionView() {
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "BlockedUserCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "blockedUserCell")
        
        collectionView.collectionViewLayout = .createFullWidthDynamicLayout(spacing: 10, contentInsets: NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0), estimatedHeight: 80)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshScreen), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func updateBlockedUserCount() {
        blockedUserCountLabel.text = String(format: "settings.blocked_users_count".localized, viewModel.getBlockedUserCount())
        
        if viewModel.getBlockedUserCount() > 0 {
            blockedUserCountLabel.isHidden = false
        } else {
            blockedUserCountLabel.isHidden = true
        }
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, BlockedUser>(collectionView: collectionView) { (collectionView, indexPath, blockedUser) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "blockedUserCell", for: indexPath) as? BlockedUserCollectionViewCell else {
                fatalError("Cannot create new cell")
            }
            cell.configure(with: self.viewModel.blockedUsers[indexPath.item])
            
            let userID = self.viewModel.blockedUsers[indexPath.item].userID
            cell.onUnblockedUserButtonTapped = { [weak self] in
                guard let self = self else { return }
                self.unblockUserRequest(userID: userID)
            }
            
            return cell
        }
    }
    
    private func updateSnapshot(with blockedUser: [BlockedUser]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, BlockedUser>()
        snapshot.appendSections([.main])
        snapshot.appendItems(blockedUser, toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func removeCellFromSnapshot(requestID: String) {
        guard let item = viewModel.blockedUsers.first(where: { $0.userID == requestID }) else { return }
        
        viewModel.blockedUsers.removeAll { $0.userID == requestID }
        
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([item])
        dataSource.apply(snapshot, animatingDifferences: true)
        
        updateBlockedUserCount()
    }
    
    private func unblockUserRequest(userID: String) {
        showTwoButtonAlert(title: "settings.blocked_unblock_confirmation_title".localized, message: "settings.blocked_unblock_confirmation_messsage".localized, firstButtonTitle: "general.button.yes".localized, firstButtonHandler: { _ in
            self.showLoading()
            Task(priority: .utility) {
                defer {
                    self.hideLoading()
                }
                await self.viewModel.unblockUser(userId: userID)
            }
        }, secondButtonTitle: "general.button.cancel".localized)
        
    }
    
    @objc private func refreshScreen() {
        Task {
            await viewModel.fetchBlockedUsers()
            collectionView.refreshControl?.endRefreshing()
        }
    }
    
}

extension BlockedUserViewController: BlockedUserViewModelDelagete, EmptyStateDisplayable {
    func didUnblockUserSuccessfully(_ userId: String) {
        DispatchQueue.main.async { [weak self] in
            self?.removeCellFromSnapshot(requestID: userId)
        }
    }
    
    func didFetchBlockedUsersSuccessfully() {
        DispatchQueue.main.async {
            self.hideEmptyState(from: self.collectionView)
            self.updateSnapshot(with: self.viewModel.blockedUsers)
        }
    }
    
    func didEmptyUserBlocks() {
        DispatchQueue.main.async {
            self.collectionView.refreshControl?.endRefreshing()
            self.showEmptyState(type: .noBlockedUsers, in: self.collectionView)
        }
    }
    
    func didError(with error: any Error) {
        DispatchQueue.main.async {
            self.handleError(error)
        }
    }
}
