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
