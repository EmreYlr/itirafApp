//
//  FlowViewController.swift
//  itirafApp
//
//  Created by Emre on 13.11.2025.
//

import UIKit

final class FlowViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewModel: FlowViewModelProtocol
    var dataSource: UICollectionViewDiffableDataSource<Section, FlowData>!
    
    required init?(coder: NSCoder) {
        self.viewModel = FlowViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        loadCollectionView()
        configureDataSource()
    }
    
    private func initView() {
        viewModel.delegate = self
        Task {
            await viewModel.fetchFlow(reset: true)
        }
    }
    
    private func loadCollectionView() {
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "ConfessionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "confessionCell")
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshFlow), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, FlowData>(collectionView: collectionView) { (collectionView, indexPath, flow) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "confessionCell", for: indexPath) as? ConfessionCollectionViewCell else {
                fatalError("Cannot create new cell")
            }
            cell.configure(with: flow)
            
            cell.onLikeButtonTapped = { [weak self] in
                guard let self = self else { return }
                
                Task {
                    await self.viewModel.toggleLikeStatus(for: flow.id)
                }
            }
            
            return cell
        }
    }
    
    private func updateSnapshot(with flow: [FlowData]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, FlowData>()
        snapshot.appendSections([.main])
        snapshot.appendItems(flow, toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    @objc private func refreshFlow() {
        Task {
            await viewModel.fetchFlow(reset: true)
        }
    }
    
}

extension FlowViewController: FlowViewModelDelegate {
    func didUpdateFlow(with data: [FlowData]) {
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
