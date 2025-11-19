//
//  ChannelCollectionViewCell.swift
//  itirafApp
//
//  Created by Emre on 13.11.2025.
//

import UIKit

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
        imageBgView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        imageBgView.backgroundColor = .systemGray6
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        subButton.layer.cornerRadius = subButton.frame.height / 2
    }
    
    func configure(with channel: ChannelData, isFollowed: Bool) {
        channelNameLabel.text = channel.title.capitalized
        subCountLabel.text = "14.4K abone"
        channelIconLabel.text = String(channel.title.prefix(2).uppercased())
                
        configureButtonAppearance(isFollowed: isFollowed)
    }
    
    @IBAction func subButtonTapped(_ sender: UIButton) {
        onSubButtonTapped?()
    }
    
    private func configureButtonAppearance(isFollowed: Bool) {
        if isFollowed {
            subButton.backgroundColor = .systemMint.withAlphaComponent(0.15)
            subButton.setTitleColor(.systemMint, for: .normal)
            subButton.setTitle("Takip Ediliyor", for: .normal)
        } else {
            subButton.backgroundColor = .systemMint
            subButton.setTitleColor(.white, for: .normal)
            subButton.setTitle("Takip Et", for: .normal)
        }
    }
}
