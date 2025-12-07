//
//  ChannelDetailViewController+CollectionView.swift
//  itirafApp
//
//  Created by Emre on 13.11.2025.
//

import UIKit

extension ChannelDetailViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
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

        if indexPath.row == totalItems - 1 && viewModel.hasMoreData && !viewModel.isLoading {
            Task {
                await viewModel.fetchConfessions(reset: false)
            }
        }
    }

}
