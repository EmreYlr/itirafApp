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
    @IBOutlet weak var channelImageView: UIImageView!
    @IBOutlet weak var imageBgView: UIView!
    
    var onSubButtonTapped: (() -> Void)?
    private var isSubscribed = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageBgView.layer.cornerRadius = imageBgView.frame.width / 2
        imageBgView.layer.borderWidth = 1
        imageBgView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        
        channelImageView.tintColor = .white
        channelImageView.clipsToBounds = true
        
        configureButtonAppearance()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        subButton.layer.cornerRadius = subButton.frame.height / 2
    }
    
    func configure(with channel: ChannelData) {
        channelNameLabel.text = channel.title.capitalized
        subCountLabel.text = "14.4K abone" //TODO: -Gerçek veri gelecek
    }
    
    @IBAction func subButtonTapped(_ sender: UIButton) {
        isSubscribed.toggle()
        
        UIView.animate(withDuration: 0.25) {
            self.configureButtonAppearance()
        }
        
        onSubButtonTapped?()
    }
    
    private func configureButtonAppearance() {
        if isSubscribed {
            subButton.backgroundColor = .systemMint.withAlphaComponent(0.15)
            subButton.setTitleColor(.systemMint, for: .normal)
            subButton.setTitle("Abone olundu", for: .normal)
        } else {
            subButton.backgroundColor = .systemMint
            subButton.setTitleColor(.white, for: .normal)
            subButton.setTitle("Abone ol", for: .normal)
        }
    }
}
