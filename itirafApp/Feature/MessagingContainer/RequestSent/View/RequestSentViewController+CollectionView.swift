//
//  RequestSentViewController+CollectionView.swift
//  itirafApp
//
//  Created by Emre on 3.11.2025.
//
import UIKit

extension RequestSentViewController:  UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let message = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        let detailVC: RequestSentDetailViewController = Storyboard.requestSent.instantiate(.requestSentDetail)
        detailVC.viewModel.sentRequests = message
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let _ = dataSource.snapshot().numberOfItems
    }
}
