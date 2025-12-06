//
//  HomeViewController+CollectionView.swift
//  itirafApp
//
//  Created by Emre on 29.09.2025.
//

import UIKit
import SkeletonView

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
        if let confession = dataSource.itemIdentifier(for: indexPath) {
            homeViewModel.didViewItem(at: confession.id)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        homeViewModel.sendPendingSeenMessages()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            homeViewModel.sendPendingSeenMessages()
        }
    }
}


class HomeDiffableDataSource: UICollectionViewDiffableDataSource<Section, ConfessionData>, SkeletonCollectionViewDataSource {
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "confessionCell"
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func numSections(in collectionSkeletonView: UICollectionView) -> Int {
        return 1
    }
}


enum Section {
    case main
}
