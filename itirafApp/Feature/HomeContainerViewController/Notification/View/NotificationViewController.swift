//
//  NotificationViewController.swift
//  itirafApp
//
//  Created by Emre on 18.11.2025.
//

import UIKit

final class NotificationViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    var dataSource: UICollectionViewDiffableDataSource<NotificationSection, NotificationItem>!
    var viewModel: NotificationViewModelProtocol
    
    var isSelectionMode = false {
        didSet {
            collectionView.allowsMultipleSelection = isSelectionMode
            updateNavigationBar()
            collectionView.visibleCells.forEach { cell in
                if let notifCell = cell as? NotificationCollectionViewCell {
                    notifCell.isSelectionMode = isSelectionMode
                }
            }
        }
    }
    var selectedIDs = Set<String>()
    
    required init?(coder: NSCoder) {
        self.viewModel = NotificationViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        setNavigationBar()
        setupCollectionView()
        configureDataSource()
        setupLongGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    private func initData() {
        viewModel.delegate = self
        fetchNotifications(reset: true)
    }
    
    private func setNavigationBar() {
        navigationItem.title = "Bildirimler"
        let deleteButton = UIBarButtonItem(title: "Tümünü Sil", style: .plain, target: self, action: #selector(deleteAllNotification))
        deleteButton.tintColor = .systemRed
        navigationItem.rightBarButtonItem = deleteButton
    }
    
    private func setupLongGesture() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        collectionView.addGestureRecognizer(longPress)
    }
    
    private func fetchNotifications(reset: Bool) {
        Task {
            defer { self.collectionView.refreshControl?.endRefreshing() }
            await viewModel.listAllNotifications(reset: reset)
        }
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self

        collectionView.register(UINib(nibName: "NotificationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "notificationCell")

        collectionView.collectionViewLayout = createLayout()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshNotification), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }

    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in

            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(90))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)

            section.interGroupSpacing = 5

            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)

            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top)
            
            section.boundarySupplementaryItems = [header]
            
            return section
        }
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<NotificationSection, NotificationItem>(collectionView: collectionView) { (collectionView, indexPath, notification) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "notificationCell", for: indexPath) as? NotificationCollectionViewCell else {
                fatalError("Cannot create new cell")
            }
            cell.configure(with: notification, isSelectionMode: self.isSelectionMode, isSelected: collectionView.indexPathsForSelectedItems?.contains(indexPath) ?? false)
            
            return cell
        }
        
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "NotificationHeaderView",
                for: indexPath) as? NotificationHeaderView else {
                return nil
            }
            
            let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            switch section {
            case .new:
                header.headerTitleLabel.text = "YENİ"
                header.markReadButton.isHidden = false
                header.onMarkReadTapped = {
                    Task(priority: .utility) {
                        await self.viewModel.setSeenAllNotifications()
                    }
                }
            case .old:
                header.headerTitleLabel.text = "DAHA ÖNCE"
                header.markReadButton.isHidden = true
            }
            
            return header
        }
    }
    
    private func updateSnapshot(with notifications: [NotificationItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<NotificationSection, NotificationItem>()

        let newNotifications = notifications.filter { !$0.seen }
        let oldNotifications = notifications.filter { $0.seen }

        if !newNotifications.isEmpty {
            snapshot.appendSections([.new])
            snapshot.appendItems(newNotifications, toSection: .new)
        }

        if !oldNotifications.isEmpty {
            snapshot.appendSections([.old])
            snapshot.appendItems(oldNotifications, toSection: .old)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func updateNavigationBar() {
        if isSelectionMode {
            navigationItem.title = "\(selectedIDs.count) Seçildi"

            let deleteButton = UIBarButtonItem(title: "Sil", style: .plain, target: self, action: #selector(deleteSelectedItems))
            deleteButton.tintColor = .systemRed
            navigationItem.rightBarButtonItem = deleteButton
            
            let cancelButton = UIBarButtonItem(title: "Vazgeç", style: .plain, target: self, action: #selector(cancelSelectionMode))
            navigationItem.leftBarButtonItem = cancelButton
        } else {
            navigationItem.rightBarButtonItem = nil
            navigationItem.leftBarButtonItem = nil
            
            setNavigationBar()
            selectedIDs.removeAll()
            if let indexPaths = collectionView.indexPathsForSelectedItems {
                for indexPath in indexPaths {
                    collectionView.deselectItem(at: indexPath, animated: true)
                }
            }
        }
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        let point = gesture.location(in: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: point) {
            isSelectionMode = true

            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)

            collectionView(collectionView, didSelectItemAt: indexPath)
        }
    }

    @objc private func cancelSelectionMode() {
        isSelectionMode = false
    }
    
    @objc private func refreshNotification() {
        fetchNotifications(reset: true)
    }
    
    @objc private func deleteSelectedItems() {
        guard !selectedIDs.isEmpty else { return }
        
        Task(priority: .utility) {
            await self.viewModel.deleteNotification(ids: Array(self.selectedIDs))
            self.isSelectionMode = false
        }
    }
    
    @objc private func deleteAllNotification() {
        showTwoButtonAlert(title: "Uyarı", message: "Tüm bildirimleri silmek istediğinize emin misin?", firstButtonTitle: "Sil", firstButtonHandler: { _ in
            Task(priority: .utility) {
                await self.viewModel.deleteAllNotifications()
            }
        }, secondButtonTitle: "İptal")
    }
}

extension NotificationViewController: NotificationViewModelDelegate {
    func didUpdateNotifiaction(with data: [NotificationItem]) {
        DispatchQueue.main.async {
            self.updateSnapshot(with: data)
        }
    }
    
    func didFailUpdateNotification(with error: any Error) {
        print("Failed to fetch notifications: \(error.localizedDescription)")
    }
}
