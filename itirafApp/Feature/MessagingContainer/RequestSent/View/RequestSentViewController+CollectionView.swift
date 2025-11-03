//
//  RequestSentViewController+CollectionView.swift
//  itirafApp
//
//  Created by Emre on 3.11.2025.
//
import UIKit

extension RequestSentViewController:  UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let message = dataSource.itemIdentifier(for: indexPath) else {
//            return
//        }
//        let chatVC: ChatViewController = Storyboard.chat.instantiate(.chat)
//        chatVC.mode = .messageRequest
//        chatVC.viewModel.requestMessage = message
//        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let _ = dataSource.snapshot().numberOfItems
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
