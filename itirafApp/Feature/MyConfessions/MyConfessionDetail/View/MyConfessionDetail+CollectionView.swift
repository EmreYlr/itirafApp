//
//  MyConfessionDetail+CollectionView.swift
//  itirafApp
//
//  Created by Emre on 30.10.2025.
//

import UIKit

extension MyConfessionDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return viewModel.myConfession?.replies?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myconfesionHeaderCell", for: indexPath) as! MyConfessionHeaderCollectionViewCell
            
            if let confession = viewModel.myConfession {
                cell.configure(with: confession)
                
                cell.onEditButtonTapped = { [weak self] in
                    self?.handleEditConfession()
                }
                
                cell.onLikeButtonTapped = {
                     Task {
                         print("Like tapped")
                     }
                }
                
                cell.onShareButtonTapped = {
                    print("Share tapped")
                }
                
                cell.onReplyButtonTapped = { [weak self] in
                    self?.replyTextField.becomeFirstResponder()
                }
            }
            return cell
        }
        
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailConfessionCell", for: indexPath) as! DetailConfessionCollectionViewCell
            
            if let reply = viewModel.myConfession?.replies?[indexPath.row] {
                cell.configure(with: reply)
            }
            return cell
        }
    }
}
