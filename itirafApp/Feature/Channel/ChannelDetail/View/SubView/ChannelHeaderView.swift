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
    
    
    func configurationView(channel: ChannelData) {
        channelNameLabel.text = channel.title
        subCountLabel.text = "14.4K abone" //TODO: -Gerçek veri gelecek
        
        //TODO: -Abone kontrolü yapılacak
//        let buttonTitle = isSubscribed ? "Abone Olundu" : "Abone Ol"
//        subButton.setTitle(buttonTitle, for: .normal)
//        subButton.backgroundColor = isSubscribed ? UIColor.gray : UIColor.systemBlue
        
        subButton.layer.cornerRadius = 8
        headerView.layer.cornerRadius = headerView.frame.width / 2
        headerView.clipsToBounds = true
        headerView.layer.borderWidth = 1
        headerView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        headerImageView.image = UIImage(named: "building_icon")
    }
    
    @IBAction func subButtonTapped(_ sender: UIButton) {
    }
}
