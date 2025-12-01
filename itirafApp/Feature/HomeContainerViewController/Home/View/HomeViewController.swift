//
//  ViewController.swift
//  itirafApp
//
//  Created by Emre on 12.09.2025.
//

import UIKit

final class HomeViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newPostButton: UIButton!
    
    var homeViewModel: HomeViewModelProtocol
    let refreshControl = UIRefreshControl()
    var dataSource: UICollectionViewDiffableDataSource<Section, ConfessionData>!
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
        
        refreshControl.addTarget(self, action: #selector(refreshConfession), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func initView() {
        homeViewModel.delegate = self
        newPostButton.layer.cornerRadius = newPostButton.frame.height / 2
        newPostButton.backgroundColor = .systemMint
        newPostButton.tintColor = .white
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateChannel), name: .channelDidChange, object: nil)
        Task {
            await homeViewModel.fetchConfessions(reset: true)
        }
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
                    await self.homeViewModel.toggleLikeStatus(for: confession.id)
                }
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
    
    @IBAction func newPostButtonTapped(_ sender: UIButton) {
        guard let tabBarView = tabBarController?.view else {
            tabBarController?.selectedIndex = 2
            return
        }
        
        UIView.transition(with: tabBarView, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.tabBarController?.selectedIndex = 2
        })
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

// MARK: - ViewModel Output
extension HomeViewController: HomeViewModelOutputProtocol {
    func didUpdateConfessions(with data: [ConfessionData]) {
        DispatchQueue.main.async {
            self.updateSnapshot(with: data)
            self.collectionView.refreshControl?.endRefreshing()
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
