//
//  NotificationViewController+CollectionView.swift
//  itirafApp
//
//  Created by Emre on 18.11.2025.
//

import UIKit
import SkeletonView

extension NotificationViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let snapshot = dataSource.snapshot()
        let sectionIdentifiers = snapshot.sectionIdentifiers
        
        guard let lastSectionIdentifier = sectionIdentifiers.last else { return }

        if indexPath.section == lastSectionIdentifier.rawValue {
            let itemsInLastSection = snapshot.itemIdentifiers(inSection: lastSectionIdentifier)
            
            if let lastItem = itemsInLastSection.last,
               let currentItem = dataSource.itemIdentifier(for: indexPath),
               lastItem == currentItem {
                
                if viewModel.hasMoreData && !viewModel.isLoading {
                    Task {
                        await viewModel.listAllNotifications(reset: false)
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        if isSelectionMode {
            selectedIDs.insert(item.id)
            navigationItem.title = "notification.selection.title".localized(selectedIDs.count)
        } else {
            collectionView.deselectItem(at: indexPath, animated: false)
            
            Task {
                if !item.seen && !recentlySeenIDs.contains(item.id) {
                    recentlySeenIDs.insert(item.id)
                    await viewModel.setSeenNotifications(ids: [item.id], shouldUpdateUI: false)
                }
            }
            
            if let cell = collectionView.cellForItem(at: indexPath) as? NotificationCollectionViewCell {
                cell.markAsSeen(animated: true)
            }

            if let route = NotificationParser.parse(item: item) {
                NotificationCenter.default.post(name: .shouldNavigateToRoute, object: route)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if isSelectionMode {
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
            selectedIDs.remove(item.id)
            navigationItem.title = "notification.selection.title".localized(selectedIDs.count)
            if selectedIDs.isEmpty {
                isSelectionMode = false
            }
        }
    }
}

class NotificationDiffableDataSource: UICollectionViewDiffableDataSource<NotificationSection, NotificationItem>, SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, supplementaryViewIdentifierOfKind kind: String, at indexPath: IndexPath) -> ReusableCellIdentifier? {
        return "NotificationHeaderView"
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "notificationCell"
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func numSections(in collectionSkeletonView: UICollectionView) -> Int {
        return 1
    }
}

enum NotificationSection: Int, CaseIterable {
    case new
    case old
}
