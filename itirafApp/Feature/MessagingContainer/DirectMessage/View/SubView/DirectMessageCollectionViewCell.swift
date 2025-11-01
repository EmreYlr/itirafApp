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
        profileBGView.backgroundColor = .systemGray
        profileImageView.tintColor = .white
        profileBGView.clipsToBounds = true
        newMessageCountView.layer.cornerRadius = newMessageCountView.frame.width / 2
        newMessageCountView.backgroundColor = .systemMint
        newMessageCountLabel.textColor = .white
        
        messageLabel.numberOfLines = 1
        messageLabel.lineBreakMode = .byTruncatingTail
    }
    
    func configure(with directMessage: DirectMessage) {
        usernameLabel.text = directMessage.username
        messageLabel.text = "\(directMessage.isLastMessageMine ? "Sen: " : "")\(directMessage.lastMessage)"
        timeLabel.text = directMessage.lastMessageDate.formattedTime()
        newMessageCountLabel.text = "1" //TODO: - yeni mesaj sayısı eklenecek
    }

}
