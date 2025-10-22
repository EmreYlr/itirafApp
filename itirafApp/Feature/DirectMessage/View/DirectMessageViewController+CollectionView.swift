//
//  DirectMessageViewController+CollectionView.swift
//  itirafApp
//
//  Created by Emre on 22.10.2025.
//

import UIKit

extension DirectMessageViewController:  UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let _ = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
//        let detailVC = Storyboard.main.instantiate(.detail) as! DetailViewController
//        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let _ = dataSource.snapshot().numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
}
