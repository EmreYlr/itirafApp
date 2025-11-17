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
        print("DirectMessageViewController")
        loadCollectionView()
        configureDataSource()
        initData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    private func initData() {
        directMessageViewModel.delegate = self
        navigationItem.title = "Mesajlar"
        
        Task {
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

        let alert = UIAlertController(title: "Seçenekler", message: "'\(message.username)' ile olan mesaj.", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Mesajları Sil", style: .default, handler: { _ in
            Task(priority: .utility) {
                await self.directMessageViewModel.deleteRoom(roomId: message.roomID, blockUser: false)
            }
        }))

        alert.addAction(UIAlertAction(title: "Mesajları Sil ve Kullanıcıyı Engelle", style: .destructive, handler: { _ in
            Task(priority: .utility) {
                await self.directMessageViewModel.deleteRoom(roomId: message.roomID, blockUser: true)
            }
        }))
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}


extension DirectMessageViewController: DirectMessageViewModelDelegate {
    func didUpdateDirectMessages() {
        updateSnapshot(with: directMessageViewModel.directMessages)
    }
    
    func didError(_ error: any Error) {
        print("Error in DirectMessageViewController: \(error.localizedDescription)")
    }
    
}
