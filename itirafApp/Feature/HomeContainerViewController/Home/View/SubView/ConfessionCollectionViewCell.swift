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
    @IBOutlet weak var blurLabel: UILabel!
    @IBOutlet weak var blurTapLabel: UILabel!
    @IBOutlet weak var nsfwBlurView: UIVisualEffectView!
    
    var onLikeButtonTapped: (() -> Void)?
    var onCommentButtonTapped: (() -> Void)?
    var onChannelTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 10
        bgView.clipsToBounds = true
        
        nsfwBlurView.layer.cornerRadius = 10
        nsfwBlurView.clipsToBounds = true
        blurLabel.text = "confession.nsfw_blur_label".localized
        blurTapLabel.text = "confession.nsfw_blur_tap_label".localized
        setupNsfwGesture()
        
        channelNameLabel.attributedText = NSAttributedString(
            string: channelNameLabel.text ?? "",
            attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue]
        )
        setupChannelLabelTap()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nsfwBlurView.isHidden = true
        nsfwBlurView.alpha = 1.0
    }
    
    func configure(with confession: ConfessionData) {
        confessionTitleLabel.text = confession.title
        confessionMessageLabel.text = confession.message
        likeCountLabel.text = "\(confession.likeCount)"
        commentCountLabel.text = "\(confession.replyCount)"
        updateLikeButton(isLiked: confession.liked)
        dateLabel.text = confession.createdAt.relativeTimeString()
        ownerNameLabel.text = confession.owner.username == UserManager.shared.getUsername() ? "confession.owner.you".localized : confession.owner.username
        channelNameLabel.isHidden = confession.channel == nil
        channelNameLabel.text = confession.channel?.title.capitalized
        
        handleNsfwState(isNsfw: confession.isNsfw)
    }
    
    func configure(with flow: FlowData) {
        confessionTitleLabel.text = flow.title
        confessionMessageLabel.text = flow.message
        likeCountLabel.text = "\(flow.likeCount)"
        commentCountLabel.text = "\(flow.replyCount)"
        updateLikeButton(isLiked: flow.liked)
        dateLabel.text = flow.createdAt.relativeTimeString()
        ownerNameLabel.text = flow.owner.username == UserManager.shared.getUsername() ? "confession.owner.you".localized : flow.owner.username
        channelNameLabel.isHidden = false
        channelNameLabel.text = flow.channel.title.capitalized
        
        handleNsfwState(isNsfw: flow.isNsfw)
    }

    private func handleNsfwState(isNsfw: Bool) {
        if isNsfw {
            nsfwBlurView.isHidden = false
            nsfwBlurView.alpha = 1.0
            bgView.bringSubviewToFront(nsfwBlurView)
        } else {
            nsfwBlurView.isHidden = true
        }
    }
    
    private func setupNsfwGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(nsfwTapped))
        nsfwBlurView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func nsfwTapped() {
        UIView.animate(withDuration: 0.3, animations: {
            self.nsfwBlurView.alpha = 0
        }) { _ in
            self.nsfwBlurView.isHidden = true
        }
    }

    @objc private func channelLabelTapped() {
        onChannelTapped?()
    }

    @IBAction func likeButtonPressed(_ sender: UIButton) {
        onLikeButtonTapped?()
    }
    
    @IBAction func commentButtonPressed(_ sender: UIButton) {
        onCommentButtonTapped?()
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
