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
    }
    
    private func loadCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ConfessionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "confessionCell")
        
    }
    
    private func initView() {
        homeViewModel.delegate = self
        homeViewModel.fetchConfessions()
        homeViewModel.onConfessionsChanged = { [weak self] _ in
            self?.collectionView.reloadData()
        }
        print(AuthManager.shared.getAccessToken() ?? "")
        print(AuthManager.shared.getRefreshToken() ?? "")
    }
    
}

extension HomeViewController: HomeViewModelOutputProtocol {
    func didUpdateConfessions() {
        print("Confessions Updated")
        collectionView.reloadData()
    }
}
