//
//  DirectMessageCollectionViewCell.swift
//  itirafApp
//
//  Created by Emre on 22.10.2025.
//

import UIKit

final class DirectMessageCollectionViewCell: UICollectionViewCell {
    //MARK: - Properties
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var newMessageCountView: UIView!
    @IBOutlet weak var newMessageCountLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileBGView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileBGView.layer.cornerRadius = profileBGView.frame.width / 2
        profileBGView.layer.borderWidth = 1
        profileBGView.layer.borderColor = UIColor.lightGray.cgColor
        
        newMessageCountView.layer.cornerRadius = newMessageCountView.frame.width / 2
        newMessageCountView.backgroundColor = .systemMint
        
        newMessageCountLabel.textColor = .white

    }
    
    func configure(with directMessage: DirectMessage) {
        usernameLabel.text = directMessage.senderUsername
        messageLabel.text = directMessage.message
        timeLabel.text = directMessage.createdAt
        newMessageCountLabel.text = "1"
    }

}
