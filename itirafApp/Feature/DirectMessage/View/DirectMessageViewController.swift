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
        navigationItem.title = "Direct Messages"
        directMessageViewModel.fetchDirectMessages()
    }
    
    private func loadCollectionView() {
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "DirectMessageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "dmCell")
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshConfession), for: .valueChanged)
        collectionView.refreshControl = refreshControl
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
    
    @objc private func refreshConfession() {
        Task {
            directMessageViewModel.fetchDirectMessages()
            collectionView.refreshControl?.endRefreshing()
        }
    }
}

extension DirectMessageViewController: DirectMessageViewModelDelegate {
    func didUpdateDirectMessages() {
        updateSnapshot(with: directMessageViewModel.directMessages)
        print("Direct messages updated")
    }
    
    func didError(_ error: any Error) {
        print("Error in DirectMessageViewController: \(error.localizedDescription)")
    }

}
