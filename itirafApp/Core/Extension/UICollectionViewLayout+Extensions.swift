//
//  UICollectionViewLayout+Extensions.swift
//  itirafApp
//
//  Created by Emre on 6.12.2025.
//

import UIKit

extension UICollectionViewLayout {
    
    /// Tam genişlikte dinamik liste layout'u oluşturur.
    /// - Parameters:
    ///   - spacing: Hücreler arası boşluk (Varsayılan: 10)
    ///   - contentInsets: Kenar boşlukları (Varsayılan: .zero)
    ///   - estimatedHeight: Hücrenin tahmini yüksekliği (Varsayılan: 100)
    ///   - headerHeight: Eğer bir Header istiyorsan buraya tahmini yüksekliğini gir Girmezsen Header oluşmaz.
    ///   - pinHeader: Header'ın yukarıda sabit kalmasını (sticky) ister misin? (Varsayılan: false)
    static func createFullWidthDynamicLayout(
        spacing: CGFloat = 10,
        contentInsets: NSDirectionalEdgeInsets = .zero,
        estimatedHeight: CGFloat = 100,
        headerHeight: CGFloat? = nil,
        pinHeader: Bool = false
    ) -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(estimatedHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(estimatedHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = contentInsets
        
        if let hHeight = headerHeight {
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(hHeight)
            )
            
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            
            header.pinToVisibleBounds = pinHeader
            
            section.boundarySupplementaryItems = [header]
        }
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
