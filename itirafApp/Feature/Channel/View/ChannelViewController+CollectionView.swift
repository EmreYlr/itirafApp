//
//  ChannelViewController+CollectionView.swift
//  itirafApp
//
//  Created by Emre on 7.10.2025.
//

import UIKit
import SkeletonView

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
        
        let isFollowed = channelViewModel.isChannelFollowed(channelId: channel.id)
        
        cell.configure(with: channel, isFollowed: isFollowed)
        
        cell.onSubButtonTapped = { [weak self] in
            Task(priority: .utility) {
                guard let self = self else { return }
                if isFollowed {
                    await self.channelViewModel.unfollowChannel(at: indexPath.row)
                } else {
                    await self.channelViewModel.followChannel(at: indexPath.row)
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let channel = channelViewModel.filterChannels[indexPath.item]
        let channelDetailVC: ChannelDetailViewController = Storyboard.channelDetail.instantiate(.channelDetail)
        channelDetailVC.viewModel = ChannelDetailViewModel(channel: channel)
        navigationController?.pushViewController(channelDetailVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard !channelViewModel.isSearching else { return }
        
        if indexPath.item == (channelViewModel.channel?.data.count ?? 0) - 1 {
            Task {
                await channelViewModel.fetchChannel(reset: false)
            }
        }
    }
}

extension ChannelViewController: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "channelCell"
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func numSections(in collectionSkeletonView: UICollectionView) -> Int {
        return 1
    }
}
