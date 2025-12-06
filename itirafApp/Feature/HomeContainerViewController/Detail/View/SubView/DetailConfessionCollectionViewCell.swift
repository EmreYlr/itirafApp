//
//  DetailConfessionCollectionViewCell.swift
//  itirafApp
//
//  Created by Emre on 6.10.2025.
//

import UIKit
import SkeletonView

final class DetailConfessionCollectionViewCell: UICollectionViewCell {
    //MARK: -Properties
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.backgroundColor = .backgroundCard
        bgView.layer.cornerRadius = 6
        messageLabel.skeletonTextNumberOfLines = 3
        messageLabel.lastLineFillPercent = 70
    }

    
    func configure(with confession: Reply) {
        messageLabel.text = confession.message
        dateLabel.text = confession.createdAt.relativeTimeString()
        if UserManager.shared.isMe(userId: confession.owner.id) {
            usernameLabel.text = "confession.owner.you".localized
            usernameLabel.textColor = .brandSecondary
            usernameLabel.font = .boldSystemFont(ofSize: usernameLabel.font.pointSize)
        } else {
            usernameLabel.text = confession.owner.username
            usernameLabel.textColor = .textPrimary
            usernameLabel.font = .systemFont(ofSize: usernameLabel.font.pointSize)
        }
        
        bgView.backgroundColor = .backgroundCard
        bgView.layer.borderWidth = 0
        bgView.layer.borderColor = UIColor.clear.cgColor
        
    }
    
    func flashAnimation() {
        UIView.animate(withDuration: 0.3, animations: {
            self.bgView.backgroundColor = UIColor.brandSecondary.withAlphaComponent(0.1)
            self.bgView.layer.borderColor = UIColor.brandSecondary.cgColor
            self.bgView.layer.borderWidth = 2
        }) { _ in

            UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut, animations: {
                self.bgView.backgroundColor = .backgroundCard
                self.bgView.layer.borderColor = UIColor.clear.cgColor
                self.bgView.layer.borderWidth = 0
            }, completion: nil)
        }
    }
}
