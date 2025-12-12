//
//  RequestSentViewController.swift
//  itirafApp
//
//  Created by Emre on 3.11.2025.
//

import UIKit

final class RequestSentViewController: UIViewController {
    //MARK: -Properties
    @IBOutlet weak var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, RequestSentModel>!
    
    var viewModel: RequestSentViewModelProtocol
    required init?(coder: NSCoder) {
        self.viewModel = RequestSentViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        initUI()
        loadCollectionView()
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        if self.isMovingToParent {
            showLoading(style: .localDimmed)
            Task {
                defer {
                    self.hideLoading()
                }
                await viewModel.fetchSentRequests()
            }
        } else {
            Task {
                await viewModel.fetchSentRequests()
            }
        }
        
    }
    
    private func initUI() {
        navigationItem.title = "request.title.sent_requests".localized
    }
    
    private func initData() {
        viewModel.delegate = self
    }
    
    private func loadCollectionView() {
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "RequestSentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "requestSentCell")
        
        collectionView.collectionViewLayout = .createFullWidthDynamicLayout(spacing: 10, contentInsets: NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0), estimatedHeight: 80)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshRS), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, RequestSentModel>(collectionView: collectionView) { (collectionView, indexPath, confession) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "requestSentCell", for: indexPath) as? RequestSentCollectionViewCell else {
                fatalError("Cannot create new cell")
            }
            cell.configure(with: self.viewModel.sentRequests[indexPath.item])
            return cell
        }
    }
    
    private func updateSnapshot(with directMessage: [RequestSentModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, RequestSentModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(directMessage, toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    @objc private func refreshRS() {
        Task {
            await viewModel.fetchSentRequests()
            collectionView.refreshControl?.endRefreshing()
        }
    }
}

extension RequestSentViewController: RequestSentViewModelDelegate, EmptyStateDisplayable {
    func didUpdateSentRequests() {
        DispatchQueue.main.async {
            self.hideEmptyState(from: self.collectionView)
            self.updateSnapshot(with: self.viewModel.sentRequests)
        }
    }
    
    func didEmptySentRequests() {
        DispatchQueue.main.async {
            self.collectionView.refreshControl?.endRefreshing()
            self.showEmptyState(type: .noSentRequestMessages, in: self.collectionView)
        }
    }
    
    func didError(error: any Error) {
        DispatchQueue.main.async {
            self.handleError(error)
        }
    }
}
