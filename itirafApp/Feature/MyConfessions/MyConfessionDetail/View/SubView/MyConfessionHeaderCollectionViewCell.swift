//
//  MyConfessionHeaderCollectionViewCell.swift
//  itirafApp
//
//  Created by Emre on 29.11.2025.
//

import UIKit

final class MyConfessionHeaderCollectionViewCell: UICollectionViewCell {
    //MARK: -Properties
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var nsfwView: UIView!
    @IBOutlet weak var statusTitleLabel: UILabel!
    @IBOutlet weak var nsfwImageView: UIImageView!
    @IBOutlet weak var nsfwLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var replyCountLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var replyTitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var channelLabel: UILabel!
    
    var onShareButtonTapped: (() -> Void)?
    var onReplyButtonTapped: (() -> Void)?
    var onLikeButtonTapped: (() -> Void)?
    var onEditButtonTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        statusView.layer.cornerRadius = statusView.frame.height / 2
        messageView.layer.cornerRadius = 10
        messageView.backgroundColor = UIColor.systemGray.withAlphaComponent(0.1)
        
        nsfwView.layer.cornerRadius = nsfwView.frame.height / 2
        
        replyTitleLabel.text = "detail.reply_section_title".localized
        statusTitleLabel.text = "confession.status_title".localized
        editButton.titleLabel?.text = "confession.button.edit".localized
    }
    
    func configure(with confessionData: MyConfessionData) {
        titleLabel.text = confessionData.title
        contentLabel.text = confessionData.message
        likeCountLabel.text = "\(confessionData.likeCount)"
        replyCountLabel.text = "\(confessionData.replyCount)"
        dateLabel.text = confessionData.createdAt.relativeTimeString()
        channelLabel.text = confessionData.channel.title
        replyTitleLabel.text = "detail.reply_section_title".localized(confessionData.replyCount)
        
        updateLikeButton(isLiked: confessionData.liked)
        configureStatus(for: confessionData)
        
        nsfwLabel.text = "confession.nsfw_blur_label".localized
        
        switch confessionData.isNsfw {
        case true:
            nsfwImageView.tintColor = .purple
            nsfwLabel.textColor = .purple
            nsfwView.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.2)
            nsfwView.isHidden = false
        case false:
            nsfwView.isHidden = true
        }
    }
    
    private func configureStatus(for data: MyConfessionData) {
        let displayStatus: ConfessionDisplayStatus
        
        switch data.moderationStatus {
        case .humanApproved, .aiApproved:
            displayStatus = .approved
        case .humanRejected, .aiRejected:
            displayStatus = .rejected
        case .pending, .needsHumanReview:
            displayStatus = .inReview
        }
        
        switch displayStatus {
        case .approved:
            statusImageView.tintColor = .systemGreen
            statusView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
            statusLabel.text = "confession.status.active".localized
            statusLabel.textColor = .systemGreen
            
            editButton.isHidden = true
            
        case .rejected:
            statusImageView.tintColor = .systemRed
            statusView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.2)
            statusLabel.text = "confession.status.rejected".localized
            statusLabel.textColor = .systemRed
            
            editButton.isHidden = false
            
        case .inReview:
            statusImageView.tintColor = .systemOrange
            statusView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.2)
            statusLabel.text = "confession.status.pending".localized
            statusLabel.textColor = .systemOrange
            
            editButton.isHidden = true
            
        case .unknown:
            statusImageView.tintColor = .systemGray
            statusView.backgroundColor = UIColor.systemGray.withAlphaComponent(0.2)
            statusLabel.text = "confession.status.unknown".localized
            statusLabel.textColor = .systemGray
            
            editButton.isHidden = true
        }
    }
    
    private func updateLikeButton(isLiked: Bool) {
        let likeImageName = isLiked ? "heart.fill" : "heart"
        let likeImage = UIImage(systemName: likeImageName)
        likeButton.setImage(likeImage, for: .normal)
        likeButton.tintColor = isLiked ? .systemMint : .systemGray
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
        onEditButtonTapped?()
    }
}
