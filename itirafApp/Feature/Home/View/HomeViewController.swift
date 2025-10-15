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
    
    required init?(coder: NSCoder) {
        self.homeViewModel = HomeViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("HomeViewController")
        initView()
        loadCollectionView()
        print(UserManager.shared.getUser() ?? "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(ChannelManager.shared.getChannel() ?? "Error")
    }
    
    private func loadCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ConfessionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "confessionCell")
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshConfession), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func initView() {
        homeViewModel.delegate = self
        homeViewModel.fetchConfessions(reset: false)
//        homeViewModel.onConfessionsChanged = { [weak self] _ in
//            self?.collectionView.reloadData()
//        }   
    }
    
    @objc private func refreshConfession() {
        homeViewModel.fetchConfessions(reset: true)
    }
    
}

extension HomeViewController: HomeViewModelOutputProtocol {
    func didUpdateConfessions() {
        print("Confessions Updated")
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    func didFailWithError(_ error: Error) {
        print("Error: \(error)")
        DispatchQueue.main.async {
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
}
