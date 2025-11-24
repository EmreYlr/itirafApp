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
        initData()
        loadCollectionView()
        configureDataSource()
    }
    
    private func initData() {
        viewModel.delegate = self
        configureNavigationBar()
        Task {
            await viewModel.fetchMyConfessions(reset: true)
        }
    }
    
    private func configureNavigationBar() {
        if viewModel.isUserAdmin() {
            let image = UIImage(systemName: "shield.lefthalf.fill")?.withTintColor(UIColor.systemMint, renderingMode: .alwaysOriginal)
            
            let moderationButton = UIBarButtonItem(
                image: image,
                style: .plain,
                target: self,
                action: #selector(moderationButtonTapped)
            )
            navigationItem.rightBarButtonItem = moderationButton
        }
    }
    
    private func loadCollectionView() {
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "MyConfessionsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "myConfessionsCell")
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
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
    
    @objc private func moderationButtonTapped() {
        let moderationVC: ModerationViewController = Storyboard.moderation.instantiate(.moderation)
        navigationController?.pushViewController(moderationVC, animated: true)
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
        DispatchQueue.main.async {
            self.handleError(error)
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
}
