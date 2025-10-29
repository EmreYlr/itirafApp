//
//  MyConfessionsViewController.swift
//  itirafApp
//
//  Created by Emre on 29.10.2025.
//

import UIKit

final class MyConfessionsViewController: UIViewController {
    //MARK: -Properties
    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewModel: MyConfessionsViewModelProtocol
    var dataSource: UICollectionViewDiffableDataSource<Section, MyConfessionData>!

    required init?(coder: NSCoder) {
        self.viewModel = MyConfessionsViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("My Confessions")
        initData()
        loadCollectionView()
        configureDataSource()
    }
    
    private func initData() {
        viewModel.delegate = self
        Task {
            await viewModel.fetchMyConfessions(reset: true)
        }
    }
    
    private func loadCollectionView() {
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "MyConfessionsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "myConfessionsCell")
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let width = collectionView.frame.width
            flowLayout.estimatedItemSize = CGSize(width: width, height: 150)
        }
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshConfession), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, MyConfessionData>(collectionView: collectionView) { (collectionView, indexPath, confession) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myConfessionsCell", for: indexPath) as? MyConfessionsCollectionViewCell else {
                fatalError("Cannot create new cell")
            }
            cell.configure(with: confession)
            
            cell.onEditButtonTapped = { [weak self] in
                guard let self = self else { return }
                let editVC: EditConfessionViewController = Storyboard.editConfession.instantiate(.editConfession)
                editVC.viewModel = EditConfessionViewModel(myConfession: confession)
                self.navigationController?.pushViewController(editVC, animated: true)
            }
            
            return cell
        }
    }
    
    private func updateSnapshot(with confessions: [MyConfessionData]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MyConfessionData>()
        snapshot.appendSections([.main])
        snapshot.appendItems(confessions, toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    @objc private func refreshConfession() {
        Task {
            defer {
                self.collectionView.refreshControl?.endRefreshing()
            }
            await viewModel.fetchMyConfessions(reset: true)
        }
    }
}

extension MyConfessionsViewController: MyConfessionsViewModelDelegate {
    func didUpdateConfessions(with data: [MyConfessionData]) {
        DispatchQueue.main.async {
            self.updateSnapshot(with: data)
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    func didError(_ error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}
