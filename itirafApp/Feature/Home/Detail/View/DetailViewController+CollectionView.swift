//
//  DetailViewController+CollectionView.swift
//  itirafApp
//
//  Created by Emre on 6.10.2025.
//

import UIKit

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = detailViewModel.confessionReplies.count
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailConfessionCell", for: indexPath) as! DetailConfessionCollectionViewCell
        let reply = detailViewModel.confessionReplies[indexPath.row]
        cell.configure(with: reply)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            
            // 1. Prototip hücreyi kullanın
            let cell = prototypeCell // 👈 Prototip hücreyi kullanıyoruz
            let reply = detailViewModel.confessionReplies[indexPath.row]
            
            // 2. Hücreyi verilerle doldurun
            cell.configure(with: reply)
            
            // 3. Hesaplama için maksimum genişliği ayarlayın
            let width = collectionView.frame.width
            
            // Soldaki Image'in ve sağdaki/soldaki boşlukların toplam genişliğini çıkarın.
            // Genişlik: (Cell Genişliği) - (sol boşluk 8) - (Image genişliği 35) - (Image-Label boşluk 10) - (sağ boşluk 8) = width - 61
            let labelHorizontalMargin: CGFloat = 8 + 35 + 10 + 8
            cell.messageLabel.preferredMaxLayoutWidth = width - labelHorizontalMargin

            // 4. layoutIfNeeded() çağrısını yapın
            // Bu, Auto Layout'u hemen hesaplamaya zorlar
            cell.layoutIfNeeded()

            // 5. System Layout Size Fitting ile dinamik yüksekliği hesaplayın
            let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
            let size = cell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)

            return size
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
}
