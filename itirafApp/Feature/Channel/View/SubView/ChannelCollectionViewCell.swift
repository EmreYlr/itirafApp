//
//  ChannelCollectionViewCell.swift
//  itirafApp
//
//  Created by Emre on 13.11.2025.
//

import UIKit
import SkeletonView

final class ChannelCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var subButton: UIButton!
    @IBOutlet weak var subCountLabel: UILabel!
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var channelIconLabel: UILabel!
    @IBOutlet weak var imageBgView: UIView!

    var onSubButtonTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageBgView.layer.cornerRadius = imageBgView.frame.width / 2
        imageBgView.layer.borderWidth = 1
        imageBgView.layer.borderColor = UIColor.divider.withAlphaComponent(0.3).cgColor
        imageBgView.backgroundColor = .backgroundCard
        
        isSkeletonable = true
        subButton.isSkeletonable = true
        subButton.skeletonCornerRadius = Float(subButton.frame.height / 2)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        subButton.layer.cornerRadius = subButton.frame.height / 2
    }

    func configure(with channel: ChannelData, isFollowed: Bool) {
        channelNameLabel.text = channel.title.capitalized
        subCountLabel.text = "14.4K abone"
        subCountLabel.isHidden = true
        channelIconLabel.text = String(channel.title.prefix(2).uppercased())
                
        configureButtonAppearance(isFollowed: isFollowed)
    }
    
    @IBAction func subButtonTapped(_ sender: UIButton) {
        onSubButtonTapped?()
    }
    
    private func configureButtonAppearance(isFollowed: Bool) {
        if isFollowed {
            subButton.backgroundColor = .brandPrimary.withAlphaComponent(0.15)
            subButton.setTitleColor(.brandPrimary, for: .normal)
            subButton.setTitle("channel.button.following".localized, for: .normal)
        } else {
            subButton.backgroundColor = .brandSecondary
            subButton.setTitleColor(.white, for: .normal)
            subButton.setTitle("channel.button.follow".localized, for: .normal)
        }
    }
}
