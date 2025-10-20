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
    var homeViewModel: HomeViewModelProtocol
    
    var dataSource: UICollectionViewDiffableDataSource<Section, ConfessionData>!

    required init?(coder: NSCoder) {
        self.homeViewModel = HomeViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("HomeViewController")
        initView()
        loadCollectionView()
        configureDataSource()
        print(UserManager.shared.getUser() ?? "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        homeViewModel.fetchConfessions(reset: true)
        print(ChannelManager.shared.getChannel() ?? "Error")
    }
    
    private func loadCollectionView() {
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "ConfessionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "confessionCell")
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshConfession), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func initView() {
        homeViewModel.delegate = self
        homeViewModel.fetchConfessions(reset: false)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, ConfessionData>(collectionView: collectionView) { (collectionView, indexPath, confession) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "confessionCell", for: indexPath) as? ConfessionCollectionViewCell else {
                fatalError("Cannot create new cell")
            }
            cell.configure(with: confession)
            
            cell.onLikeButtonTapped = { [weak self] in
                self?.homeViewModel.toggleLikeStatus(for: confession.id)
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
    
    @objc private func refreshConfession() {
        homeViewModel.fetchConfessions(reset: true)
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
        print("Error: \(error)")
        DispatchQueue.main.async {
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
}
