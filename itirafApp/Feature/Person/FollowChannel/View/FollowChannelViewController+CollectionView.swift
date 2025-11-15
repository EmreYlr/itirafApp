//
//  FollowChannelViewController+CollectionView.swift
//  itirafApp
//
//  Created by Emre on 15.11.2025.
//

import UIKit

extension FollowChannelViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let channelCount = viewModel.filterFollowedChannels.count
        return channelCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "channelCell", for: indexPath) as? ChannelCollectionViewCell else {
            fatalError("Cannot dequeue cell with identifier channelCell")
        }
        
        let followedChannel = viewModel.filterFollowedChannels[indexPath.item]
        let isFollowed = viewModel.isChannelFollowed(channelId: followedChannel.id)
        
        cell.configure(with: followedChannel, isFollowed: isFollowed)
        
        cell.onSubButtonTapped = { [weak self] in
            Task(priority: .utility) {
                guard let self = self else { return }
                if isFollowed {
                    await self.viewModel.unfollowChannel(at: indexPath.row)
                } else {
                    await self.viewModel.followChannel(at: indexPath.row)
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let channel = viewModel.filterFollowedChannels[indexPath.item]
        let channelDetailVC: ChannelDetailViewController = Storyboard.channelDetail.instantiate(.channelDetail)
        channelDetailVC.viewModel = ChannelDetailViewModel(channel: channel)
        navigationController?.pushViewController(channelDetailVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
}
