//
//  ChannelViewController+CollectionView.swift
//  itirafApp
//
//  Created by Emre on 7.10.2025.
//

import UIKit

extension ChannelViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let channelCount = channelViewModel.filterChannels.count
        return channelCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "channelCell", for: indexPath) as? ChannelCollectionViewCell else {
             fatalError("Cannot dequeue cell with identifier channelCell")
        }
        
        let channel = channelViewModel.filterChannels[indexPath.item]
        
        cell.configure(with: channel)
        cell.onSubButtonTapped = {
            //
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        channelViewModel.selectChannel(at: indexPath.item)

        let channel = channelViewModel.filterChannels[indexPath.item]
        let channelDetailVC: ChannelDetailViewController = Storyboard.channelDetail.instantiate(.channelDetail)
        channelDetailVC.viewModel = ChannelDetailViewModel(channel: channel)
        navigationController?.pushViewController(channelDetailVC, animated: true)
        
//        tabBarController?.selectedIndex = 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard !channelViewModel.isSearching else { return }

        if indexPath.item == (channelViewModel.channel?.data.count ?? 0) - 1 {
            Task {
                await channelViewModel.fetchChannel(reset: false)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
}
