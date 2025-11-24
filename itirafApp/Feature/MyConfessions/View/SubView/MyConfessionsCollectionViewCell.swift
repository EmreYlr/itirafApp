//
//  MyConfessionsCollectionViewCell.swift
//  itirafApp
//
//  Created by Emre on 29.10.2025.
//

import UIKit

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
    
    private let labelHorizontalMargin: CGFloat = 16
    var onEditButtonTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 10
        bgView.backgroundColor = .systemGray6
        editButton.layer.cornerRadius = 6
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        statusView.layer.cornerRadius = statusView.frame.height / 2
    }
    
    func configure(with confession: MyConfessionData) {
        titleLabel.text = confession.title
        messageLabel.text = confession.message
        likeCountLabel.text = "\(confession.likeCount)"
        replyCountLabel.text = "\(confession.replyCount)"
        timeLabel.text = confession.createdAt.relativeTimeString()
        
        messageLabel.preferredMaxLayoutWidth = self.bounds.width - labelHorizontalMargin
        titleLabel.preferredMaxLayoutWidth = self.bounds.width - labelHorizontalMargin
        
        switch confession.moderationStatus {
        case .humanApproved, .aiApproved:
            statusView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
            statusImageView.tintColor = .systemGreen
            statusLabel.textColor = .systemGreen
            statusLabel.text = "confession.status.active".localized
            editButton.isHidden = true
        case .humanRejected, .aiRejected:
            statusView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.2)
            statusImageView.tintColor = .systemRed
            statusLabel.textColor = .systemRed
            statusLabel.text = "confession.status.rejected".localized
            editButton.isHidden = false
        case .pending, .needsHumanReview:
            statusView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.2)
            statusImageView.tintColor = .systemOrange
            statusLabel.textColor = .systemOrange
            statusLabel.text = "confession.status.pending".localized
            editButton.isHidden = true
        }
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        onEditButtonTapped?()
    }
    
}
