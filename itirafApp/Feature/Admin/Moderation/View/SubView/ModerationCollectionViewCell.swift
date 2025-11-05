//
//  ModerationCollectionViewCell.swift
//  itirafApp
//
//  Created by Emre on 5.11.2025.
//

import UIKit

final class ModerationCollectionViewCell: UICollectionViewCell {
    //MARK: -Properties
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var approveButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var channelLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 10
        bgView.backgroundColor = .systemGray6
        approveButton.layer.cornerRadius = 6
        rejectButton.layer.cornerRadius = 6
    }
    
    func configure(with moderationItem: ModerationData) {
        titleLabel.text = moderationItem.title
        messageLabel.text = moderationItem.message
        dateLabel.text = moderationItem.createdAt.formattedDateTime()
        ownerLabel.text = "\(moderationItem.ownerUsername)"
        channelLabel.text = "\(moderationItem.channelTitle)"
    }

    @IBAction func approveButtonTapped(_ sender: UIButton) {
    }
    @IBAction func rejectButtonTapped(_ sender: UIButton) {
    }
}
