//
//  ConfessionCollectionViewCell.swift
//  itirafApp
//
//  Created by Emre on 29.09.2025.
//

import UIKit
import SkeletonView

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
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var dmButton: UIButton!
    
    var onLikeButtonTapped: (() -> Void)?
    var onCommentButtonTapped: (() -> Void)?
    var onChannelTapped: (() -> Void)?
    var onDMButtonTapped: (() -> Void)?
    var onShareButtonTapped: (() -> Void)?
    var onNsfwRevealed: (() -> Void)?
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .divider
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
        
        confessionMessageLabel.skeletonTextNumberOfLines = 3
        confessionMessageLabel.lastLineFillPercent = 50
        
        setupChannelLabelTap()
        setupSeparator()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nsfwBlurView.isHidden = true
        nsfwBlurView.alpha = 1.0
    }
    
    func configure(with confession: ConfessionData, isRevealed: Bool) {
        confessionTitleLabel.text = confession.title
        setMessageWithReadMore(text: confession.message)
        likeCountLabel.text = "\(confession.likeCount)"
        commentCountLabel.text = "\(confession.replyCount)"
        updateLikeButton(isLiked: confession.liked, animated: false)
        updateLikeCount(newCount: confession.likeCount, animated: false)
        dateLabel.text = confession.createdAt.relativeTimeString()
        ownerNameLabel.text = UserManager.shared.isMe(userId: confession.owner.id) ? "confession.owner.you".localized : confession.owner.username
        channelNameLabel.isHidden = confession.channel == nil
        channelNameLabel.text = confession.channel?.title.capitalized
        
        if UserManager.shared.isMe(userId: confession.owner.id) {
            dmButton.isHidden = true
        } else {
            dmButton.isHidden = false
        }
        
        handleNsfwState(isNsfw: confession.isNsfw && !isRevealed)
    }
    
    func configure(with flow: FlowData, isRevealed: Bool) {
        confessionTitleLabel.text = flow.title
        setMessageWithReadMore(text: flow.message)
        likeCountLabel.text = "\(flow.likeCount)"
        commentCountLabel.text = "\(flow.replyCount)"
        updateLikeButton(isLiked: flow.liked, animated: false)
        updateLikeCount(newCount: flow.likeCount, animated: false)
        dateLabel.text = flow.createdAt.relativeTimeString()
        ownerNameLabel.text = UserManager.shared.isMe(userId: flow.owner.id) ? "confession.owner.you".localized : flow.owner.username
        channelNameLabel.isHidden = false
        channelNameLabel.text = flow.channel.title.capitalized
        
        if UserManager.shared.isMe(userId: flow.owner.id) {
            dmButton.isHidden = true
        } else {
            dmButton.isHidden = false
        }
        
        handleNsfwState(isNsfw: flow.isNsfw && !isRevealed)
    }
    
    private func setupSeparator() {
        contentView.addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    private func handleNsfwState(isNsfw: Bool) {
        if isNsfw {
            nsfwBlurView.isHidden = false
            nsfwBlurView.alpha = 1
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
            self.onNsfwRevealed?()
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
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        onShareButtonTapped?()
    }
    
    @IBAction func dmButtonTapped(_ sender: UIButton) {
        onDMButtonTapped?()
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
        animation.subtype = isIncreasing ? .fromTop : .fromBottom
        animation.duration = 0.25
        
        likeCountLabel.layer.add(animation, forKey: "kCATransitionPush")
        likeCountLabel.text = "\(newCount)"
    }
    
    private func setupChannelLabelTap() {
        channelNameLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(channelLabelTapped))
        channelNameLabel.addGestureRecognizer(tapGesture)
    }
    
    private func setMessageWithReadMore(text: String) {
        let maxLength = 300
        
        if text.count > maxLength {
            let truncatedText = String(text.prefix(maxLength))
            let readMoreSuffix = "confession.read_more".localized
            
            let mainAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.textSecondary,
                .font: confessionMessageLabel.font ?? UIFont.systemFont(ofSize: 14)
            ]
            
            let suffixAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.brandPrimary,
                .font: UIFont.boldSystemFont(ofSize: confessionMessageLabel.font.pointSize)
            ]
            
            let fullString = NSMutableAttributedString(string: truncatedText, attributes: mainAttributes)
            let suffixString = NSAttributedString(string: readMoreSuffix, attributes: suffixAttributes)
            
            fullString.append(suffixString)
            confessionMessageLabel.attributedText = fullString
        } else {
            confessionMessageLabel.text = text
            confessionMessageLabel.textColor = .textSecondary
        }
    }
}
