//
//  ChannelHeaderView.swift
//  itirafApp
//
//  Created by Emre on 13.11.2025.
//

import UIKit

final class ChannelHeaderView: UICollectionReusableView {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var subCountLabel: UILabel!
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var subButton: UIButton!
    
    var onSubButtonTapped: (() -> Void)?
    
    func configurationView(channel: ChannelData, isFollowed: Bool) {
        channelNameLabel.text = channel.title.capitalized
        subCountLabel.text = "14.4K abone" //TODO: -Gerçek veri gelecek
        
        configureButtonAppearance(isFollowed: isFollowed)
        
        subButton.layer.cornerRadius = 8
        headerView.layer.cornerRadius = headerView.frame.width / 2
        headerView.clipsToBounds = true
        headerView.layer.borderWidth = 1
        headerView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        headerImageView.image = UIImage(named: "building_icon")
    }
    
    private func configureButtonAppearance(isFollowed: Bool) {
        if isFollowed {
            subButton.backgroundColor = .systemMint.withAlphaComponent(0.15)
            subButton.setTitleColor(.systemMint, for: .normal)
            subButton.setTitle("Abone olundu", for: .normal)
        } else {
            subButton.backgroundColor = .systemMint
            subButton.setTitleColor(.white, for: .normal)
            subButton.setTitle("Abone ol", for: .normal)
        }
    }
    
    @IBAction func subButtonTapped(_ sender: UIButton) {
        onSubButtonTapped?()
    }
}
