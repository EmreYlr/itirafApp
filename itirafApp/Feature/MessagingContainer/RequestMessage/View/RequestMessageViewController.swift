//
//  RequestMessageViewController.swift
//  itirafApp
//
//  Created by Emre on 1.11.2025.
//

import UIKit

final class RequestMessageViewController: UIViewController {
    //MARK: -Properties
    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewModel: RequestMessageViewModelProtocol
    var dataSource: UICollectionViewDiffableDataSource<Section, RequestMessageModel>!
    required init?(coder: NSCoder) {
        self.viewModel = RequestMessageViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("RequestMessage")
        initData()
        loadCollectionView()
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    private func initData() {
        viewModel.delegate = self
        
        Task {
            await viewModel.getPendingMessages()
        }
    }
    
    private func loadCollectionView() {
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "RequestMessageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "requestCell")
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshRM), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, RequestMessageModel>(collectionView: collectionView) { (collectionView, indexPath, confession) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "requestCell", for: indexPath) as? RequestMessageCollectionViewCell else {
                fatalError("Cannot create new cell")
            }
            cell.configure(with: self.viewModel.requestMessageModel[indexPath.item])
            let requestID = self.viewModel.requestMessageModel[indexPath.item].requestID
            cell.onApproveButtonTapped = { [weak self] in
                guard let self = self else { return }
                self.approveRequest(requestID: requestID)
            }
            cell.onRejectButtonTapped = { [weak self] in
                guard let self = self else { return }
                self.rejectRequest(requestID: requestID)
            }
            return cell
        }
    }
    
    private func updateSnapshot(with directMessage: [RequestMessageModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, RequestMessageModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(directMessage, toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func approveRequest(requestID: String) {
        Task {
            await viewModel.approveRequest(requestID: requestID)
        }
    }
    
    private func rejectRequest(requestID: String) {
        Task {
            await viewModel.rejectRequest(requestID: requestID)
        }
    }
    
    @objc private func refreshRM() {
        Task {
            await viewModel.getPendingMessages()
            collectionView.refreshControl?.endRefreshing()
        }
    }
    
    private func removeCellFromSnapshot(requestID: String) {
        guard let item = viewModel.requestMessageModel.first(where: { $0.requestID == requestID }) else { return }

        viewModel.requestMessageModel.removeAll { $0.requestID == requestID }

        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([item])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension RequestMessageViewController: RequestMessageViewModelDelegate {
    func didApproveRequest(requestID: String) {
        removeCellFromSnapshot(requestID: requestID)
        print("Approved")
    }
    
    func didRejectRequest(requestID: String) {
        removeCellFromSnapshot(requestID: requestID)
        print("Rejected")
    }
    
    func didUpdateRequestMessages() {
        updateSnapshot(with: viewModel.requestMessageModel)
    }
    
    func didError(with error: any Error) {
        print(error)
    }
}
