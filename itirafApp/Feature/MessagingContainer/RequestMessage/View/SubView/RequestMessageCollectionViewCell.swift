//
//  RequestMessageCollectionViewCell.swift
//  itirafApp
//
//  Created by Emre on 1.11.2025.
//

import UIKit

final class RequestMessageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileBGView: UIView!
    
    var onApproveButtonTapped: (() -> Void)?
    var onRejectButtonTapped: (() -> Void)?
    //MARK: -Properties
    override func awakeFromNib() {
        super.awakeFromNib()
        profileBGView.layer.cornerRadius = profileBGView.frame.width / 2
        profileBGView.backgroundColor = .systemGray
        profileImageView.tintColor = .white
        profileBGView.clipsToBounds = true
    }
    
    func configure(with requestMesage: RequestMessageModel) {
        usernameLabel.text = requestMesage.requesterUsername
        messageLabel.text = "Yeni Mesaj İsteği"
    }
    
    @IBAction func rejectButtonTapped(_ sender: UIButton) {
        onRejectButtonTapped?()
    }
    
    @IBAction func approveButtonTapped(_ sender: UIButton) {
        onApproveButtonTapped?()
    }
}
