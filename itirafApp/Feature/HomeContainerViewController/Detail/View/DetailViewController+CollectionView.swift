//
//  DetailViewController+CollectionView.swift
//  itirafApp
//
//  Created by Emre on 6.10.2025.
//

import UIKit
import SkeletonView

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, SkeletonCollectionViewDataSource {
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        if indexPath.section == 0 {
            return "detailHeaderCell"
        } else {
            return "detailConfessionCell"
        }
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 5
        }
    }
    
    func numSections(in collectionSkeletonView: UICollectionView) -> Int {
        return 2
    }
    
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
                    guard let self = self else { return }

                    let isCurrentlyLiked = self.detailViewModel.confession?.liked ?? false
                    let futureState = !isCurrentlyLiked

                    cell.updateLikeButton(isLiked: futureState, animated: true)

                    self.handleLikeAction()
                }
                
                cell.onShareButtonTapped = { [weak self] in
                    self?.handleShareAction()
                }
                
                cell.onReplyButtonTapped = { [weak self] in
                    self?.handleReplyButtonAction()
                }
                
                cell.onDMButtonTapped = { [weak self] in
                    self?.handleDMButtonAction()
                }
                
                cell.onAdminEditButtonTapped = { [weak self] in
                    self?.handleAdminEditConfession()
                }
                
                cell.onReportTapped = { [weak self] in
                    self?.handleReportConfession()
                }
                
                cell.onDeleteTapped = { [weak self] in
                    self?.handleDeleteConfession()
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
}
