//
//  DetailViewController+CollectionView.swift
//  itirafApp
//
//  Created by Emre on 6.10.2025.
//

import UIKit

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return detailViewModel.confession == nil ? 0 : 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return detailViewModel.confession?.replies.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailHeaderCell", for: indexPath) as! DetailHeaderCollectionViewCell
            
            if let confession = detailViewModel.confession {
                cell.configure(with: confession)
                
                cell.onLikeButtonTapped = { [weak self] in
                    self?.handleLikeAction()
                }
                
                cell.onShareButtonTapped = { [weak self] in
                    self?.handleShareAction()
                }
                
                cell.onReplyButtonTapped = { [weak self] in
                    self?.handleReplyButtonAction()
                }
            }
            return cell
        }
        
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailConfessionCell", for: indexPath) as! DetailConfessionCollectionViewCell
            
            if let reply = detailViewModel.confession?.replies[indexPath.row] {
                cell.configure(with: reply)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8, bottom: 10, right: 8)
    }
}
