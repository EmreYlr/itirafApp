//
//  RequestSentCollectionViewCell.swift
//  itirafApp
//
//  Created by Emre on 3.11.2025.
//

import UIKit

final class RequestSentCollectionViewCell: UICollectionViewCell {
    //MARK: -Properties
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileBGView: UIView!
    @IBOutlet weak var profileIconLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 10
        bgView.backgroundColor = .backgroundCard
        bgView.layer.borderWidth = 0.2
        bgView.layer.borderColor = UIColor.divider.cgColor
        
        profileBGView.layer.cornerRadius = profileBGView.frame.width / 2
        profileBGView.backgroundColor = .backgroundApp
        profileBGView.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        statusView.layer.cornerRadius = statusView.frame.height / 2
    }
    
    func configure(with sentRequest: RequestSentModel) {
        usernameLabel.text = sentRequest.confessionAuthorUsername
        messageLabel.text = "direct_message.prefix.you".localized + sentRequest.initialMessage
        profileIconLabel.text = String(sentRequest.confessionAuthorUsername.prefix(2)).uppercased()
        
        switch sentRequest.status {
        case .pending:
            statusView.backgroundColor = UIColor.statusPending.withAlphaComponent(0.2)
            statusLabel.textColor = .statusPending
            statusLabel.text = "request.status.pending".localized
        case .rejected:
            statusView.backgroundColor = UIColor.statusError.withAlphaComponent(0.2)
            statusLabel.textColor = .statusError
            statusLabel.text = "request.status.rejected".localized
        }
    }
}
