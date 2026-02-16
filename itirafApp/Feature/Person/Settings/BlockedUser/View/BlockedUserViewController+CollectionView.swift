//
//  BlockedUserViewController+CollectionView.swift
//  itirafApp
//
//  Created by Emre on 16.02.2026.
//

import UIKit

extension BlockedUserViewController:  UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let _ = dataSource.snapshot().numberOfItems
    }
}
