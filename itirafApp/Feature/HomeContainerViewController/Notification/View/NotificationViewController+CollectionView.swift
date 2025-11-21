//
//  NotificationViewController+CollectionView.swift
//  itirafApp
//
//  Created by Emre on 18.11.2025.
//


import UIKit

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
    //TODO: -Tıklanan bildiirme git
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        if isSelectionMode {
            selectedIDs.insert(item.id)
            navigationItem.title = "\(selectedIDs.count) Seçildi"
        } else {
            collectionView.deselectItem(at: indexPath, animated: false)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if isSelectionMode {
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
            selectedIDs.remove(item.id)
            navigationItem.title = "\(selectedIDs.count) Seçildi"
            if selectedIDs.isEmpty {
                isSelectionMode = false
            }
        }
    }
}

enum NotificationSection: Int, CaseIterable {
    case new
    case old
}
