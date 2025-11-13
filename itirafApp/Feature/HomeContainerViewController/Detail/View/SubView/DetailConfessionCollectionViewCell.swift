//
//  DetailConfessionCollectionViewCell.swift
//  itirafApp
//
//  Created by Emre on 6.10.2025.
//

import UIKit

final class DetailConfessionCollectionViewCell: UICollectionViewCell {
    //MARK: -Properties
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.backgroundColor = .lightGray.withAlphaComponent(0.1)
        bgView.layer.cornerRadius = 6
    }

    
    func configure(with confession: Reply) {
        messageLabel.text = confession.message
        dateLabel.text = confession.createdAt.relativeTimeString()
        if confession.owner.username == UserManager.shared.getUsername() {
            usernameLabel.text = "Sen"
            usernameLabel.textColor = .systemMint
            usernameLabel.font = .boldSystemFont(ofSize: usernameLabel.font.pointSize)
        } else {
            usernameLabel.text = confession.owner.username
            usernameLabel.textColor = .label
            usernameLabel.font = .systemFont(ofSize: usernameLabel.font.pointSize)
        }
        
        let labelHorizontalMargin: CGFloat = 61
        messageLabel.preferredMaxLayoutWidth = self.bounds.width - labelHorizontalMargin
    }
}
