//
//  HomeViewController+CollectionView.swift
//  itirafApp
//
//  Created by Emre on 29.09.2025.
//

import UIKit

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return homeViewModel.confessions?.data.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "confessionCell", for: indexPath) as! ConfessionCollectionViewCell
        
        if let confession = homeViewModel.confessions?.data[indexPath.row] {
            cell.configure(with: confession)
        }

//        cell.onLikeButtonTapped = { [weak self] in
//            self?.homeViewModel.toggleLike(at: indexPath.row)
//        }
//        
//        cell.onCommentButtonTapped = { [weak self] in
//            self?.homeViewModel.addComment(to: indexPath.row)
//        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detail = Storyboard.main.instantiate(.detail) as! DetailViewController
        if let confession = homeViewModel.confessions?.data[indexPath.row] {
            detail.detailViewModel = DetailViewModel(confession: confession)
        }
        navigationController?.pushViewController(detail, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let totalCount = homeViewModel.confessions?.data.count else { return }
        
        if indexPath.row == totalCount - 1 {
            homeViewModel.fetchConfessions(reset: false)
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
