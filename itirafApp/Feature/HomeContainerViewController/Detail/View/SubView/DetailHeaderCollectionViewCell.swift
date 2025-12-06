//
//  DetailHeaderCollectionViewCell.swift
//  itirafApp
//
//  Created by Emre on 29.11.2025.
//

import UIKit

final class DetailHeaderCollectionViewCell: UICollectionViewCell {
    //MARK: -Properties
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var replyCountLabel: UILabel!
    @IBOutlet weak var replyTitleLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    var onShareButtonTapped: (() -> Void)?
    var onReplyButtonTapped: (() -> Void)?
    var onLikeButtonTapped: (() -> Void)?
    var onAdminEditButtonTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        replyTitleLabel.text = "detail.reply_section_title".localized
        editButton.isHidden = !UserManager.shared.hasRole(.admin)
        contentLabel.skeletonTextNumberOfLines = 3
        contentLabel.lastLineFillPercent = 50
    }
    
    func configure(with confessionData: ChannelMessageData) {
        titleLabel.text = confessionData.title
        contentLabel.text = confessionData.message
        ownerNameLabel.text = UserManager.shared.isMe(userId: confessionData.owner.id) ? "confession.owner.you".localized: confessionData.owner.username
        dateLabel.text = confessionData.createdAt.relativeTimeString()
        likeCountLabel.text = "\(confessionData.likeCount)"
        replyCountLabel.text = "\(confessionData.replyCount)"
        updateLikeButton(isLiked: confessionData.liked, animated: false)
        channelNameLabel.text = confessionData.channel.title
        
        replyTitleLabel.text = "detail.reply_section_title".localized(confessionData.replyCount)
    }
    
    func updateLikeButton(isLiked: Bool, animated: Bool = false) {
        let imageName = isLiked ? "heart.fill" : "heart"
        likeButton.tintColor = isLiked ? .actionLike : .textSecondary
        likeButton.setImage(UIImage(systemName: imageName), for: .normal)
        if animated {
            likeButton.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 6.0, options: .allowUserInteraction, animations: {
                self.likeButton.transform = .identity
            }, completion: nil)
        } else {
            likeButton.transform = .identity
        }
    }

    func updateLikeCount(newCount: Int, animated: Bool = true) {
        guard animated else {
            likeCountLabel.text = "\(newCount)"
            return
        }
        
        let currentCount = Int(likeCountLabel.text ?? "0") ?? 0
        let isIncreasing = newCount > currentCount
        
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.type = .push
        animation.duration = 0.25

        animation.subtype = isIncreasing ? .fromTop : .fromBottom

        likeCountLabel.layer.add(animation, forKey: "kCATransitionPush")

        likeCountLabel.text = "\(newCount)"
    }
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        onLikeButtonTapped?()
    }

    @IBAction func replyButtonTapped(_ sender: UIButton) {
        onReplyButtonTapped?()
    }

    @IBAction func shareButtonTapped(_ sender: UIButton) {
        onShareButtonTapped?()
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        onAdminEditButtonTapped?()
    }
}
