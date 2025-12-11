//
//  DetailConfessionCollectionViewCell.swift
//  itirafApp
//
//  Created by Emre on 6.10.2025.
//

import UIKit
import SkeletonView

final class DetailConfessionCollectionViewCell: UICollectionViewCell {
    //MARK: -Properties
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var menuButton: UIButton!
    
    var onReportTapped: (() -> Void)?
    var onDeleteTapped: (() -> Void)?
    var onBlockTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.backgroundColor = .backgroundCard
        bgView.layer.cornerRadius = 6
        messageLabel.skeletonTextNumberOfLines = 3
        messageLabel.lastLineFillPercent = 70
        usernameLabel.textColor = .textPrimary
    }

    
    func configure(with confession: Reply) {
        messageLabel.text = confession.message
        dateLabel.text = confession.createdAt.relativeTimeString()
        if UserManager.shared.isMe(userId: confession.owner.id) {
            usernameLabel.text = "confession.owner.you".localized
            usernameLabel.font = .boldSystemFont(ofSize: usernameLabel.font.pointSize)
            setupMenu(isOwner: true)
        } else {
            usernameLabel.text = confession.owner.username
            usernameLabel.font = .systemFont(ofSize: usernameLabel.font.pointSize)
            menuButton.isHidden = false
            setupMenu(isOwner: false)
        }
        
        bgView.backgroundColor = .backgroundCard
        bgView.layer.borderWidth = 0
        bgView.layer.borderColor = UIColor.clear.cgColor
        
    }
    
    func setupMenu(isOwner: Bool) {
        var menuItems: [UIMenuElement] = []
        
        if isOwner {
            let deleteAction = UIAction(title: "general.button.delete".localized, image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                self?.onDeleteTapped?()
            }
            menuItems.append(deleteAction)
            
        } else {
            let reportAction = UIAction(title: "general.button.report".localized, image: UIImage(systemName: "exclamationmark.bubble"), attributes: .destructive) { [weak self] _ in
                self?.onReportTapped?()
            }

            let blockAction = UIAction(title: "direct_message.action.block".localized, image: UIImage(systemName: "hand.raised.slash")) { [weak self] _ in
                self?.onBlockTapped?()
            }
            
            menuItems.append(blockAction)
            menuItems.append(reportAction)
        }

        menuButton.menu = UIMenu(title: "", children: menuItems)
        menuButton.showsMenuAsPrimaryAction = true
    }
    
    func flashAnimation() {
        UIView.animate(withDuration: 0.3, animations: {
            self.bgView.backgroundColor = UIColor.brandSecondary.withAlphaComponent(0.1)
            self.bgView.layer.borderColor = UIColor.brandSecondary.cgColor
            self.bgView.layer.borderWidth = 2
        }) { _ in

            UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut, animations: {
                self.bgView.backgroundColor = .backgroundCard
                self.bgView.layer.borderColor = UIColor.clear.cgColor
                self.bgView.layer.borderWidth = 0
            }, completion: nil)
        }
    }
}
