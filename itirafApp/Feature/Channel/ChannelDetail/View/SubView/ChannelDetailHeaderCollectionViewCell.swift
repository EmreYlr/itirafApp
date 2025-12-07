//
//  ChannelDetailHeaderCollectionViewCell.swift
//  itirafApp
//
//  Created by Emre on 7.12.2025.
//

import UIKit

final class ChannelDetailHeaderCollectionViewCell: UICollectionViewCell {
    //MARK: - Properties
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var subCountLabel: UILabel!
    @IBOutlet weak var subButton: UIButton!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var bgView: UIView!
    
    var onSubButtonTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configurationView(channel: ChannelData, isFollowed: Bool) {
        channelNameLabel.text = channel.title.capitalized
        subCountLabel.text = "14.4K abone" //TODO: -Gerçek veri gelecek
        
        configureButtonAppearance(isFollowed: isFollowed)
        
        subButton.layer.cornerRadius = 8
        headerView.layer.cornerRadius = headerView.frame.width / 2
        headerView.clipsToBounds = true
        headerView.layer.borderWidth = 1
        headerView.layer.borderColor = UIColor.divider.withAlphaComponent(0.3).cgColor
        headerImageView.image = UIImage(named: "building_icon")
    }
    
    private func configureButtonAppearance(isFollowed: Bool) {
        if isFollowed {
            subButton.backgroundColor = .brandPrimary.withAlphaComponent(0.15)
            subButton.setTitleColor(.brandPrimary, for: .normal)
            subButton.setTitle("channel.button.following".localized, for: .normal)
        } else {
            subButton.backgroundColor = .brandSecondary
            subButton.setTitleColor(.textPrimary, for: .normal)
            subButton.setTitle("channel.button.follow".localized, for: .normal)
        }
    }
    
    @IBAction func subButtonTapped(_ sender: UIButton) {
        onSubButtonTapped?()
    }
    
}
