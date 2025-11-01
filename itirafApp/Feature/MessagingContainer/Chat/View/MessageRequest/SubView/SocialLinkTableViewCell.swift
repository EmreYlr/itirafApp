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
        bgView.backgroundColor = .lightGray.withAlphaComponent(0.1)
        bgView.layer.cornerRadius = 6
        platformIconView.layer.cornerRadius = 8
        platformIconView.backgroundColor = .lightGray.withAlphaComponent(0.2)
        platformIconView.clipsToBounds = true
    }
    
    func configure(with link: Link) {
        usernameLabel.text = link.username
        platformNameLabel.text = link.platform.displayName
        platformIconImageView.image = UIImage(named: link.platform.iconName)
        arrowImageView.isHidden = false
    }
    
    func configureForAnonymous() {
        usernameLabel.text = "Anonimlik tercih edildi."
        platformNameLabel.text = "Sosyal medya bilgileri gizli tuttuluyor."
        platformIconImageView.image = UIImage(systemName: "person.fill.xmark")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        arrowImageView.isHidden = true
    }

}
