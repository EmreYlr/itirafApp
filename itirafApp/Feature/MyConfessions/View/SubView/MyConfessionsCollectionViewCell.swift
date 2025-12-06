//
//  MyConfessionsCollectionViewCell.swift
//  itirafApp
//
//  Created by Emre on 29.10.2025.
//

import UIKit
import SkeletonView

final class MyConfessionsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var replyCountLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nsfwView: UIView!
    @IBOutlet weak var nsfwImageView: UIImageView!
    @IBOutlet weak var nsfwLabel: UILabel!
    
    var onEditButtonTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 10
        bgView.backgroundColor = .backgroundCard
        editButton.layer.cornerRadius = 6
        nsfwView.layer.cornerRadius = nsfwView.frame.height / 2
        nsfwLabel.text = "confession.nsfw_blur_label".localized
        
        messageLabel.skeletonTextNumberOfLines = 3
        messageLabel.lastLineFillPercent = 50
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        statusView.layer.cornerRadius = statusView.frame.height / 2
    }
    
    func configure(with confession: MyConfessionData) {
        titleLabel.text = confession.title
        setMessageWithReadMore(text: confession.message)
        likeCountLabel.text = "\(confession.likeCount)"
        replyCountLabel.text = "\(confession.replyCount)"
        timeLabel.text = confession.createdAt.relativeTimeString()
        
        switch confession.isNsfw {
        case true:
            nsfwImageView.tintColor = .sensitiveAccent
            nsfwLabel.textColor = .sensitiveAccent
            nsfwView.backgroundColor = UIColor.sensitiveAccent.withAlphaComponent(0.2)
            nsfwView.isHidden = false
        case false:
            nsfwView.isHidden = true
        }
        
        switch confession.moderationStatus {
        case .humanApproved, .aiApproved:
            statusView.backgroundColor = UIColor.statusSuccess.withAlphaComponent(0.2)
            statusImageView.tintColor = .statusSuccess
            statusLabel.textColor = .statusSuccess
            statusLabel.text = "confession.status.active".localized
            editButton.isHidden = true
        case .humanRejected, .aiRejected:
            statusView.backgroundColor = UIColor.statusError.withAlphaComponent(0.2)
            statusImageView.tintColor = .statusError
            statusLabel.textColor = .statusError
            statusLabel.text = "confession.status.rejected".localized
            editButton.isHidden = false
        case .pending, .needsHumanReview:
            statusView.backgroundColor = UIColor.statusPending.withAlphaComponent(0.2)
            statusImageView.tintColor = .statusPending
            statusLabel.textColor = .statusPending
            statusLabel.text = "confession.status.pending".localized
            editButton.isHidden = true
        }
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        onEditButtonTapped?()
    }
    
    private func setMessageWithReadMore(text: String) {
        let maxLength = 300
        
        if text.count > maxLength {
            let truncatedText = String(text.prefix(maxLength))
            let readMoreSuffix = "confession.read_more".localized
            
            let mainAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.textSecondary,
                .font: messageLabel.font ?? UIFont.systemFont(ofSize: 14)
            ]
            
            let suffixAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.brandPrimary,
                .font: UIFont.boldSystemFont(ofSize: messageLabel.font.pointSize)
            ]
            
            let fullString = NSMutableAttributedString(string: truncatedText, attributes: mainAttributes)
            let suffixString = NSAttributedString(string: readMoreSuffix, attributes: suffixAttributes)
            
            fullString.append(suffixString)
            messageLabel.attributedText = fullString
        } else {
            messageLabel.text = text
            messageLabel.textColor = .textSecondary
        }
    }
}
