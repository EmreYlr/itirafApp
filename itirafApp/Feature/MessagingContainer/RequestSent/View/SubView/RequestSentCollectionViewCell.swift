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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 10
        bgView.backgroundColor = .systemGray5.withAlphaComponent(0.2)
        bgView.layer.borderWidth = 0.2
        bgView.layer.borderColor = UIColor.systemGray2.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        statusView.layer.cornerRadius = statusView.frame.height / 2
    }
    
    func configure(with sentRequest: RequestSentModel) {
        usernameLabel.text = sentRequest.confessionAuthorUsername
        messageLabel.text = sentRequest.initialMessage
        
        switch sentRequest.status {
        case .pending:
            statusView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.2)
            statusLabel.textColor = .systemOrange
            statusLabel.text = "request.status.pending".localized
        case .rejected:
            statusView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.2)
            statusLabel.textColor = .systemRed
            statusLabel.text = "request.status.rejected".localized
        }
    }
}
