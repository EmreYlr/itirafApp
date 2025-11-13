//
//  HomeViewController+CollectionView.swift
//  itirafApp
//
//  Created by Emre on 29.09.2025.
//

import UIKit

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let confession = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        let detailVC = Storyboard.main.instantiate(.detail) as! DetailViewController
        detailVC.detailViewModel = DetailViewModel(messageId: confession.id)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let totalItems = dataSource.snapshot().numberOfItems

        if indexPath.row == totalItems - 1 && homeViewModel.hasMoreData && !homeViewModel.isLoading {
            Task {
                await homeViewModel.fetchConfessions(reset: false)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
}

enum Section {
    case main
}
