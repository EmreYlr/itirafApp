//
//  ModerationViewController.swift
//  itirafApp
//
//  Created by Emre on 5.11.2025.
//

import UIKit

final class ModerationViewController: UIViewController {
    //MARK: -Properties
    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewModel: ModerationViewModelProtocol
    var dataSource: UICollectionViewDiffableDataSource<Section, ModerationData>!
    
    required init?(coder: NSCoder) {
        self.viewModel = ModerationViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Moderation")
        initData()
        loadCollectionView()
        configureDataSource()
    }
    
    private func initData() {
        viewModel.delegate = self
        
        configureNavigationBar()
        Task {
            await viewModel.fetchModerationData(reset: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    private func configureNavigationBar() {
        self.title = "Moderasyon"
    }
    //TODO: -Reject olanları ayırmak için label koy
    private func loadCollectionView() {
        collectionView.delegate = self
        
        collectionView.register(UINib(nibName: "ModerationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "moderationCell")
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let width = collectionView.frame.width
            flowLayout.estimatedItemSize = CGSize(width: width, height: 150)
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, ModerationData>(collectionView: collectionView) { (collectionView, indexPath, moderationItem) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "moderationCell", for: indexPath) as? ModerationCollectionViewCell else {
                fatalError("Cannot create new cell (ModerationCollectionViewCell)")
            }
            
            cell.configure(with: moderationItem)
            
            cell.onApproveButtonTapped = { [weak self] in
                guard let self = self else { return }
                self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                self.collectionView.delegate?.collectionView?(self.collectionView, didSelectItemAt: indexPath)
            }
            
            cell.onRejectButtonTapped = { [weak self] in
                guard let self = self else { return }
                self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                self.collectionView.delegate?.collectionView?(self.collectionView, didSelectItemAt: indexPath)
            }
            
            return cell
        }
    }
    
    private func updateSnapshot(with items: [ModerationData]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ModerationData>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    @objc private func refreshData() {
        Task {
            defer {
                self.collectionView.refreshControl?.endRefreshing()
            }
            await viewModel.fetchModerationData(reset: true)
        }
    }
    
}

extension ModerationViewController: ModerationViewModelDelegate {
    func didUpdateModerationItems(with data: [ModerationData]) {
        DispatchQueue.main.async {
            self.updateSnapshot(with: data)
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    func didFailWithError(_ error: any Error) {
        print("Error: \(error.localizedDescription)")
    }
    
}
