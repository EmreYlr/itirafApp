//
//  SocialLinkTableViewCell.swift
//  itirafApp
//
//  Created by Emre on 1.11.2025.
//

import UIKit

final class SocialLinkTableViewCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var platformNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var platformIconImageView: UIImageView!
    @IBOutlet weak var platformIconView: UIView!
    @IBOutlet weak var arrowImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.backgroundColor = .backgroundCard
        bgView.layer.cornerRadius = 6
        platformIconView.layer.cornerRadius = 8
        platformIconView.backgroundColor = .backgroundCard
        platformIconView.clipsToBounds = true
    }
    
    func configure(with link: Link) {
        usernameLabel.text = link.username
        platformNameLabel.text = link.platform.displayName
        platformIconImageView.image = UIImage(named: link.platform.iconName)
        arrowImageView.isHidden = false
    }
    
    func configureForAnonymous() {
        usernameLabel.text = "social.anonymous.username".localized
        platformNameLabel.text = "social.anonymous.platform".localized
        platformIconImageView.image = UIImage(systemName: "person.fill.xmark")?.withTintColor(.textSecondary, renderingMode: .alwaysOriginal)
        arrowImageView.isHidden = true
    }

}
