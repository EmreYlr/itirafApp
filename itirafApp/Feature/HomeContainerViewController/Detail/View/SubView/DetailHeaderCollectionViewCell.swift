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
    
    var onShareButtonTapped: (() -> Void)?
    var onReplyButtonTapped: (() -> Void)?
    var onLikeButtonTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        replyTitleLabel.text = "detail.reply_section_title".localized
    }
    
    func configure(with confessionData: ChannelMessageData) {
        titleLabel.text = confessionData.title
        contentLabel.text = confessionData.message
        ownerNameLabel.text = confessionData.owner.username
        dateLabel.text = confessionData.createdAt.relativeTimeString()
        likeCountLabel.text = "\(confessionData.likeCount)"
        replyCountLabel.text = "\(confessionData.replyCount)"
        updateLikeButton(isLiked: confessionData.liked)
        
        replyTitleLabel.text = "detail.reply_section_title".localized(confessionData.replyCount)
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
}
