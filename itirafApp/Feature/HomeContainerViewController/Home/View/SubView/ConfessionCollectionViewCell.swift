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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 10
        
    }
    
    func configure(with confession: ConfessionData) {
        confessionTitleLabel.text = confession.title
        confessionMessageLabel.text = confession.message
        likeCountLabel.text = "\(confession.likeCount)"
        commentCountLabel.text = "\(confession.replyCount)"
        updateLikeButton(isLiked: confession.liked)
        dateLabel.text = confession.createdAt.relativeTimeString()
        ownerNameLabel.text = confession.owner.username
        channelNameLabel.isHidden = true
//        channelNameLabel.text = confession.channelName //TODO:- eklenecek
    }
    
    func configure(with flow: FlowData) {
        confessionTitleLabel.text = flow.title
        confessionMessageLabel.text = flow.message
        likeCountLabel.text = "\(flow.likeCount)"
        commentCountLabel.text = "\(flow.replyCount)"
        updateLikeButton(isLiked: flow.liked)
        dateLabel.text = flow.createdAt.relativeTimeString()
        ownerNameLabel.text = flow.owner.username
        channelNameLabel.isHidden = false
        channelNameLabel.text = flow.channel.title
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
}
