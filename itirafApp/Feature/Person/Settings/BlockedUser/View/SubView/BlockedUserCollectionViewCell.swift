//
//  BlockedUserCollectionViewCell.swift
//  itirafApp
//
//  Created by Emre on 16.02.2026.
//

import UIKit

class BlockedUserCollectionViewCell: UICollectionViewCell {
    //MARK: - Properties
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var blockedDateLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var unblockButton: UIButton!
    @IBOutlet weak var profileIconBgView: UIView!
    
    var onUnblockedUserButtonTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 10
        bgView.backgroundColor = .backgroundCard
        bgView.layer.borderWidth = 0.2
        bgView.layer.borderColor = UIColor.divider.cgColor
        
        profileIconBgView.layer.cornerRadius = profileIconBgView.frame.width / 2
        profileIconBgView.backgroundColor = .backgroundApp
        profileIconBgView.clipsToBounds = true
        
        unblockButton.layer.cornerRadius = unblockButton.frame.height / 2
        unblockButton.backgroundColor = .statusError.withAlphaComponent(0.2)
        unblockButton.setTitle("settings.blocked_users_unblock_button".localized, for: .normal)
    }
    
    func configure(with blockUser: BlockedUser) {
        usernameLabel.text = blockUser.username
        blockedDateLabel.text = blockUser.blockedAt.formattedDateTime()
    }

    @IBAction func unblockButtonTapped(_ sender: UIButton) {
        onUnblockedUserButtonTapped?()
    }
}
