//
//  SettingsViewController+CollectionView.swift
//  itirafApp
//
//  Created by Emre on 31.10.2025.
//
import UIKit

extension SettingsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        handleSelection(for: item.type)
    }
}
