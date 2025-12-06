//
//  FlowViewController+CollectionView.swift
//  itirafApp
//
//  Created by Emre on 13.11.2025.
//
import UIKit
import SkeletonView

extension FlowViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let flow = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        let detailVC = Storyboard.main.instantiate(.detail) as! DetailViewController
        detailVC.detailViewModel = DetailViewModel(messageId: flow.id)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let totalItems = dataSource.snapshot().numberOfItems

        if indexPath.row == totalItems - 1 && viewModel.hasMoreData && !viewModel.isLoading {
            Task {
                await viewModel.fetchFlow(reset: false)
            }
        }
        if let flow = dataSource.itemIdentifier(for: indexPath) {
            viewModel.didViewItem(at: flow.id)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        viewModel.sendPendingSeenMessages()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            viewModel.sendPendingSeenMessages()
        }
    }
}

class FlowDiffableDataSource: UICollectionViewDiffableDataSource<Section, FlowData>, SkeletonCollectionViewDataSource {
    
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
