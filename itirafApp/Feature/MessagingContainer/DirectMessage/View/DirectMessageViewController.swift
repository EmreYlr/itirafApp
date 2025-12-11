//
//  DirectMessageViewController.swift
//  itirafApp
//
//  Created by Emre on 22.10.2025.
//

import UIKit

final class DirectMessageViewController: UIViewController {
    //MARK: -Properties
    @IBOutlet weak var collectionView: UICollectionView!
    var directMessageViewModel: DirectMessageViewModelProtocol
    var dataSource: UICollectionViewDiffableDataSource<Section, DirectMessage>!
    
    required init?(coder: NSCoder) {
        directMessageViewModel = DirectMessageViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCollectionView()
        configureDataSource()
        initData()
    }
    
    private func initData() {
        directMessageViewModel.delegate = self
        navigationItem.title = "direct_message.title".localized
        showLoading()
        Task {
            defer {
                self.hideLoading()
            }
            await directMessageViewModel.fetchDirectMessages()
        }
    }
    
    private func loadCollectionView() {
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "DirectMessageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "dmCell")
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshDM), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, DirectMessage>(collectionView: collectionView) { (collectionView, indexPath, confession) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dmCell", for: indexPath) as? DirectMessageCollectionViewCell else {
                fatalError("Cannot create new cell")
            }
            cell.configure(with: self.directMessageViewModel.directMessages[indexPath.item])
            
            return cell
        }
    }
    
    private func updateSnapshot(with directMessage: [DirectMessage]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, DirectMessage>()
        snapshot.appendSections([.main])
        snapshot.appendItems(directMessage, toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    @objc private func refreshDM() {
        Task {
            await directMessageViewModel.fetchDirectMessages()
            collectionView.refreshControl?.endRefreshing()
        }
    }
    
    @objc private func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }

        let location = gestureRecognizer.location(in: collectionView)

        guard let indexPath = collectionView.indexPathForItem(at: location) else {
            return
        }
        guard let message = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        let alert = UIAlertController(title: "direct_message.options.title".localized, message: "direct_message.options.message".localized(message.username), preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "direct_message.action.delete_messages".localized, style: .default, handler: { _ in
            Task(priority: .utility) {
                await self.directMessageViewModel.deleteRoom(roomId: message.roomID, blockUser: false)
            }
        }))

        alert.addAction(UIAlertAction(title: "direct_message.action.block".localized, style: .destructive, handler: { _ in
            Task(priority: .utility) {
                await self.directMessageViewModel.deleteRoom(roomId: message.roomID, blockUser: true)
            }
        }))
        alert.addAction(UIAlertAction(title: "general.button.cancel".localized, style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}


extension DirectMessageViewController: DirectMessageViewModelDelegate, EmptyStateDisplayable {
    func didUpdateDirectMessages() {
        DispatchQueue.main.async {
            self.hideEmptyState(from: self.collectionView)
            self.updateSnapshot(with: self.directMessageViewModel.directMessages)
        }
        
    }
    
    func didEmptyDirectMessages() {
        DispatchQueue.main.async {
            self.collectionView.refreshControl?.endRefreshing()
            self.showEmptyState(type: .noMessages, in: self.collectionView)
        }
    }
    
    func didError(_ error: any Error) {
        DispatchQueue.main.async {
            self.handleError(error)
        }
    }
}
