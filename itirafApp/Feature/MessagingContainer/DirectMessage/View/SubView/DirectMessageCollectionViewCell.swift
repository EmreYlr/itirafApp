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
    @IBOutlet weak var profileBGView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileBGView.layer.cornerRadius = profileBGView.frame.width / 2
        profileBGView.backgroundColor = .backgroundCard
        profileBGView.clipsToBounds = true
        newMessageCountView.layer.cornerRadius = newMessageCountView.frame.width / 2
        newMessageCountView.backgroundColor = .brandSecondary
        newMessageCountLabel.textColor = .white
        
        messageLabel.numberOfLines = 1
        messageLabel.lineBreakMode = .byTruncatingTail
    }
    
    func configure(with directMessage: DirectMessage) {
        usernameLabel.text = directMessage.username
        messageLabel.text = "\(directMessage.isLastMessageMine ? "direct_message.prefix.you".localized : "")\(directMessage.lastMessage)"
        timeLabel.text = directMessage.lastMessageDate.relativeTimeString()
        if directMessage.unreadMessageCount == 0 {
            newMessageCountView.isHidden = true
        } else {
            newMessageCountView.isHidden = false
        }
        newMessageCountLabel.text = "\(directMessage.unreadMessageCount)"
    }

}
