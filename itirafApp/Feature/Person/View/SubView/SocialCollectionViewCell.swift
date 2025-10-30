//
//  SocialCollectionViewCell.swift
//  itirafApp
//
//  Created by Emre on 30.10.2025.
//

import UIKit

final class SocialCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var platformNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.backgroundColor = .lightGray.withAlphaComponent(0.1)
        bgView.layer.cornerRadius = 6
        iconView.layer.cornerRadius = 8
        iconView.backgroundColor = .lightGray.withAlphaComponent(0.2)
        iconView.clipsToBounds = true
    }
    
    func configure(with link: Link) {
        usernameLabel.text = link.username
        platformNameLabel.text = link.platform.rawValue
        iconImageView.image = UIImage(named: link.platform.iconName)
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
    }
}
