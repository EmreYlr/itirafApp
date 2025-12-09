//
//  TermsViewController+CollectionView.swift
//  itirafApp
//
//  Created by Emre on 9.12.2025.
//

import UIKit

extension TermsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.terms.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "termsCell", for: indexPath) as? TermsCollectionViewCell else {
            return UICollectionViewCell()
        }
        let term = viewModel.terms[indexPath.item]
        cell.configure(with: term)
        return cell
    }
}
