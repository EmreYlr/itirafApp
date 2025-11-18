//
//  NotificationCollectionViewCell.swift
//  itirafApp
//
//  Created by Emre on 18.11.2025.
//

import UIKit

final class NotificationCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var badgeImageView: UIImageView!
    @IBOutlet weak var badgeView: UIView!
    
    private var item: NotificationItem?
    
    override var isSelected: Bool { didSet { updateAppearance() } }
    var isSelectionMode: Bool = false { didSet { updateAppearance() } }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 8
        badgeView.layer.cornerRadius = badgeView.frame.height / 2
    }
    
    func configure(with notification: NotificationItem) {
        self.item = notification
        
        titleLabel.text = notification.title
        messageLabel.text = notification.body
        timeLabel.text = notification.createdAt.relativeTimeString()
        badgeImageView.image = notification.iconImage
        
        updateAppearance()
    }
    
    private func updateAppearance() {
        guard let item = item else { return }
        
        UIView.animate(withDuration: 0.2) {
            if self.isSelectionMode && self.isSelected {
                self.setupStyle(bgColor: .systemRed.withAlphaComponent(0.1), borderColor: .systemRed, borderWidth: 2, badgeColor: item.badgeColor, titleWeight: .medium, timeColor: .secondaryLabel)
            }
            else if item.seen {
                self.setupStyle(bgColor: .systemGray6, borderColor: .clear, borderWidth: 0, badgeColor: .systemGray5, titleWeight: .regular, timeColor: .secondaryLabel, iconTint: .black)
            }
            else {
                self.setupStyle(bgColor: .systemBlue.withAlphaComponent(0.1), borderColor: .systemBlue.withAlphaComponent(0.3), borderWidth: 1, badgeColor: item.badgeColor, titleWeight: .semibold, timeColor: .systemBlue, iconTint: .white)
            }
        }
    }
    
    private func setupStyle(bgColor: UIColor, borderColor: UIColor, borderWidth: CGFloat, badgeColor: UIColor, titleWeight: UIFont.Weight, timeColor: UIColor, iconTint: UIColor? = nil) {
        bgView.backgroundColor = bgColor
        bgView.layer.borderColor = borderColor.cgColor
        bgView.layer.borderWidth = borderWidth
        
        badgeView.backgroundColor = badgeColor
        titleLabel.font = .systemFont(ofSize: 16, weight: titleWeight)
        timeLabel.textColor = timeColor
        
        if let tint = iconTint {
            badgeImageView.tintColor = tint
        }
    }
}

extension NotificationItem {
    var badgeColor: UIColor {
        switch type {
        case .like: return .systemRed
        case .dmMessage: return .systemBlue
        case .dmRequest: return .systemPurple
        case .dmResponse: return .systemTeal
        case .reply: return .systemGreen
        case .moderation: return .systemOrange
        case .unknown: return .systemGray
        }
    }
    
    var iconImage: UIImage? {
        switch type {
        case .like: return UIImage(systemName: "heart")
        case .dmMessage: return UIImage(systemName: "bubble.left")
        case .dmRequest: return UIImage(systemName: "person.badge.plus")
        case .dmResponse: return UIImage(systemName: "person")
        case .reply: return UIImage(systemName: "text.bubble")
        case .moderation: return UIImage(systemName: "shield")
        case .unknown: return UIImage(systemName: "bell")
        }
    }
}
