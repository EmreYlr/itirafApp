//
//  ConfessionCollectionViewCell.swift
//  itirafApp
//
//  Created by Emre on 29.09.2025.
//

import UIKit

final class ConfessionCollectionViewCell: UICollectionViewCell {
    //MARK: - Properties
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var confessionTitleLabel: UILabel!
    @IBOutlet weak var confessionMessageLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var onLikeButtonTapped: (() -> Void)?
    var onCommentButtonTapped: (() -> Void)?
    var onChannelTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 10
        channelNameLabel.attributedText = NSAttributedString(
            string: channelNameLabel.text ?? "",
            attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue]
        )
        setupChannelLabelTap()
    }
    
    func configure(with confession: ConfessionData) {
        confessionTitleLabel.text = confession.title
        confessionMessageLabel.text = confession.message
        likeCountLabel.text = "\(confession.likeCount)"
        commentCountLabel.text = "\(confession.replyCount)"
        updateLikeButton(isLiked: confession.liked)
        dateLabel.text = confession.createdAt.relativeTimeString()
        ownerNameLabel.text = confession.owner.username == UserManager.shared.getUsername() ? "Sen" : confession.owner.username
        channelNameLabel.isHidden = confession.channel == nil
        channelNameLabel.text = confession.channel?.title.capitalized
    }
    
    func configure(with flow: FlowData) {
        confessionTitleLabel.text = flow.title
        confessionMessageLabel.text = flow.message
        likeCountLabel.text = "\(flow.likeCount)"
        commentCountLabel.text = "\(flow.replyCount)"
        updateLikeButton(isLiked: flow.liked)
        dateLabel.text = flow.createdAt.relativeTimeString()
        ownerNameLabel.text = flow.owner.username == UserManager.shared.getUsername() ? "Sen" : flow.owner.username
        channelNameLabel.isHidden = false
        channelNameLabel.text = flow.channel.title.capitalized
    }

    @objc private func channelLabelTapped() {
        onChannelTapped?()
    }

    @IBAction func likeButtonPressed(_ sender: UIButton) {
        onLikeButtonTapped?()
    }
    
    @IBAction func commentButtonPressed(_ sender: UIButton) { onCommentButtonTapped?()
    }
    
    func updateLikeButton(isLiked: Bool) {
        let imageName = isLiked ? "heart.fill" : "heart"
        likeButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    private func setupChannelLabelTap() {
        channelNameLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(channelLabelTapped))
        channelNameLabel.addGestureRecognizer(tapGesture)
    }
}
