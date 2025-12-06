//
//  PersonViewController+CollectionView.swift
//  itirafApp
//
//  Created by Emre on 31.10.2025.
//
import UIKit
import SkeletonView

extension PersonViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "socialCell"
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func numSections(in collectionSkeletonView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = personViewModel.socialLinks?.links.count ?? 0
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "socialCell", for: indexPath) as! SocialCollectionViewCell
        
        if let link = personViewModel.socialLinks?.links[indexPath.row] {
            cell.configure(with: link)
            cell.onEditButtonTapped = { [weak self] in
                self?.openEditSocial(link: link)
            }
            
            cell.onSwitchToggled = { [weak self] isVisible in
                self?.handleSocialLinkVisibilityChange(for: link, isVisible: isVisible, on: cell)
            }
        }
        
        return cell
    }
    
    private func openEditSocial(link: Link) {
        let editSocialVC: EditSocialViewController = Storyboard.editSocial.instantiate(.editSocial)
        editSocialVC.viewModel = EditSocialViewModel(socialLink: link)
        editSocialVC.source = .editButton
        navigationController?.pushViewController(editSocialVC, animated: true)
    }
    
    private func handleSocialLinkVisibilityChange(for link: Link, isVisible: Bool, on cell: SocialCollectionViewCell) {
        Task {
            do {
                try await personViewModel.updateUserSocialLinksVisibility(id: link.id, isVisible: isVisible)
            } catch {
                cell.visibleSwitch.setOn(!isVisible, animated: true)
                cell.configure(with: link)
            }
        }
    }
    
}
