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
                
//                cell.onBlockTapped = { [weak self] in
//                    self?.handleBlockUser(userId: reply.owner.id, isReply: false)
//                }
            }
            return cell
        }
        
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailConfessionCell", for: indexPath) as! DetailConfessionCollectionViewCell
            
            if let reply = detailViewModel.confession?.replies[indexPath.row] {
                cell.configure(with: reply)
                
                cell.onReportTapped = { [weak self] in
                    self?.handleReportReply(replyId: reply.id)
                }
                
                cell.onDeleteTapped = { [weak self] in
                    self?.handleDeleteReply(replyId: reply.id)
                }
                
//                cell.onBlockTapped = { [weak self] in
//                    self?.handleBlockUser(userId: reply.owner.id, isReply: true)
//                }
            }
            return cell
        }
    }
    
    //Basılı tutma ile açılan menü
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPath.section == 1,
              let reply = detailViewModel.confession?.replies[indexPath.row] else {
            return nil
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self = self else { return nil }
            
            var actions: [UIAction] = []
            let isOwner = UserManager.shared.isMe(userId: reply.owner.id)
            
            if isOwner {
                let deleteAction = UIAction(title: "general.button.delete".localized, image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                    self.handleDeleteReply(replyId: reply.id)
                }
                actions.append(deleteAction)
                
            } else {
                let reportAction = UIAction(title: "general.button.report".localized, image: UIImage(systemName: "exclamationmark.bubble"), attributes: .destructive) { action in
                    self.handleReportReply(replyId: reply.id)
                }
                let blockAction = UIAction(title: "direct_message.action.block".localized, image: UIImage(systemName: "hand.raised.slash")) { action in
                    // self.handleBlockUser(userId: reply.owner.id, isReply: true)
                    print("Kullanıcı engellendi: \(reply.owner.id)")
                }
                
                actions.append(blockAction)
                actions.append(reportAction)
            }
            
            return UIMenu(title: "", children: actions)
        }
    }
}
