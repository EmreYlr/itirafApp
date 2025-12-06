//
//  UICollectionViewLayout+Extensions.swift
//  itirafApp
//
//  Created by Emre on 6.12.2025.
//

import UIKit

extension UICollectionViewLayout {
    
    /// Tam genişlikte (Width %100) ve içeriğe göre uzayan (Dynamic Height) bir liste düzeni döner.
    /// - Parameters:
    ///   - spacing: Satırlar arası boşluk (Varsayılan: 10)
    ///   - contentInsets: Kenar boşlukları (Varsayılan: .zero)
    ///   - estimatedHeight: Tahmini başlangıç yüksekliği (Performans için)
    static func createFullWidthDynamicLayout(
        spacing: CGFloat = 10,
        contentInsets: NSDirectionalEdgeInsets = .zero,
        estimatedHeight: CGFloat = 100
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
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
