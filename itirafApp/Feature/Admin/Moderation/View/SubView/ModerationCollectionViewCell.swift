//
//  ModerationCollectionViewCell.swift
//  itirafApp
//
//  Created by Emre on 5.11.2025.
//

import UIKit

final class ModerationCollectionViewCell: UICollectionViewCell {
    //MARK: -Properties
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var approveButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var channelLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    
    var onApproveButtonTapped: (() -> Void)?
    var onRejectButtonTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 10
        bgView.backgroundColor = .backgroundCard
        approveButton.layer.cornerRadius = 6
        rejectButton.layer.cornerRadius = 6
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        statusView.layer.cornerRadius = statusView.frame.height / 2
    }
    
    func configure(with moderationItem: ModerationData) {
        titleLabel.text = moderationItem.title
        messageLabel.text = moderationItem.message
        dateLabel.text = moderationItem.createdAt.formattedDateTime()
        ownerLabel.text = "\(moderationItem.ownerUsername)"
        channelLabel.text = "\(moderationItem.channelTitle)"
        
        switch moderationItem.moderationStatus {
        case .humanApproved, .aiApproved:
            statusView.backgroundColor = UIColor.statusSuccess.withAlphaComponent(0.2)
            statusImageView.tintColor = .statusSuccess
            statusLabel.textColor = .statusSuccess
            statusLabel.text = "moderation.status.active".localized
        case .humanRejected, .aiRejected:
            statusView.backgroundColor = UIColor.statusError.withAlphaComponent(0.2)
            statusImageView.tintColor = .statusError
            statusLabel.textColor = .statusError
            statusLabel.text = "moderation.status.rejected".localized
        case .pending, .needsHumanReview:
            statusView.backgroundColor = UIColor.statusPending.withAlphaComponent(0.2)
            statusImageView.tintColor = .statusPending
            statusLabel.textColor = .statusPending
            statusLabel.text = "moderation.status.pending".localized
        }
    }

    @IBAction func approveButtonTapped(_ sender: UIButton) {
        onApproveButtonTapped?()
    }
    @IBAction func rejectButtonTapped(_ sender: UIButton) {
        onRejectButtonTapped?()
    }
}
