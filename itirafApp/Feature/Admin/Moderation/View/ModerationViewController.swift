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
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var viewModel: ModerationViewModelProtocol
    var dataSource: UICollectionViewDiffableDataSource<Section, ModerationData>!
    
    required init?(coder: NSCoder) {
        self.viewModel = ModerationViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        loadCollectionView()
        configureDataSource()
        configureSegmentControl()
    }
    
    private func initData() {
        viewModel.delegate = self
        
        configureNavigationBar()
        Task {
            await viewModel.fetchModerationData(reset: true)
        }
    }
    
    private func configureSegmentControl() {
        segmentControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        viewModel.setFilter(.all)
        segmentControl.selectedSegmentTintColor = .systemMint.withAlphaComponent(0.7)
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
    
    private func loadCollectionView() {
        collectionView.delegate = self
        
        collectionView.register(UINib(nibName: "ModerationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "moderationCell")
    
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
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
                guard let currentIndexPath = self.dataSource.indexPath(for: moderationItem) else { return }
                
                self.collectionView.selectItem(at: currentIndexPath, animated: false, scrollPosition: [])
                self.collectionView.delegate?.collectionView?(self.collectionView, didSelectItemAt: currentIndexPath)
            }
            
            cell.onRejectButtonTapped = { [weak self] in
                guard let self = self else { return }
                guard let currentIndexPath = self.dataSource.indexPath(for: moderationItem) else { return }
                
                self.collectionView.selectItem(at: currentIndexPath, animated: false, scrollPosition: [])
                self.collectionView.delegate?.collectionView?(self.collectionView, didSelectItemAt: currentIndexPath)
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
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            viewModel.setFilter(.all)
            sender.selectedSegmentTintColor = .systemMint.withAlphaComponent(0.7)
        case 1:
            viewModel.setFilter(.pending)
            sender.selectedSegmentTintColor = .systemOrange.withAlphaComponent(0.7)
        case 2:
            viewModel.setFilter(.rejected)
            sender.selectedSegmentTintColor = .systemRed.withAlphaComponent(0.7)
        default:
            viewModel.setFilter(.all)
            sender.selectedSegmentTintColor = .systemMint
        }
    }
    
}

extension ModerationViewController: ModerationViewModelDelegate {
    func didUpdateModerationItems() {
        DispatchQueue.main.async {
            let items = self.viewModel.filteredItems
            self.updateSnapshot(with: items)
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    func didFailWithError(_ error: any Error) {
        DispatchQueue.main.async {
            self.collectionView.refreshControl?.endRefreshing()
            self.handleError(error)
        }
    }
    
}
