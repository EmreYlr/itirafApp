//
//  MyConfessionViewController+CollectionView.swift
//  itirafApp
//
//  Created by Emre on 29.10.2025.
//

import UIKit
import SkeletonView

extension MyConfessionsViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let myConfession = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        let detailVC: MyConfessionDetailViewController = Storyboard.main.instantiate(.myConfessionDetail)
        detailVC.viewModel = MyConfessionDetailViewModel(myConfession: myConfession)
        navigationController?.pushViewController(detailVC, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let totalItems = dataSource.snapshot().numberOfItems

        if indexPath.row == totalItems - 1 && viewModel.hasMoreData && !viewModel.isLoading {
            Task {
                await viewModel.fetchMyConfessions(reset: false)
            }
        }
    }
}

class MyConfessionDiffableDataSource: UICollectionViewDiffableDataSource<Section, MyConfessionData>, SkeletonCollectionViewDataSource {
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "myConfessionsCell"
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func numSections(in collectionSkeletonView: UICollectionView) -> Int {
        return 1
    }
}
