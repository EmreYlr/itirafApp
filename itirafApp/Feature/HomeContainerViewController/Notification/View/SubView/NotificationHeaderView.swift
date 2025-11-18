//
//  NotificationHeaderView.swift
//  itirafApp
//
//  Created by Emre on 18.11.2025.
//

import UIKit

final class NotificationHeaderView: UICollectionReusableView {
    @IBOutlet weak var markReadButton: UIButton!
    @IBOutlet weak var headerTitleLabel: UILabel!
    var onMarkReadTapped: (() -> Void)?
    
    @IBAction func markReadActionTapped(_ sender: UIButton) {
        onMarkReadTapped?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onMarkReadTapped = nil
        markReadButton.isHidden = false
        headerTitleLabel.text = nil
    }
}
