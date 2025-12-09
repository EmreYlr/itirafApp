//
//  TermsCollectionViewCell.swift
//  itirafApp
//
//  Created by Emre on 9.12.2025.
//

import UIKit

final class TermsCollectionViewCell: UICollectionViewCell {
    //MARK: -Properties
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconBgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        iconBgView.layer.cornerRadius = iconBgView.frame.height / 2
        iconBgView.clipsToBounds = true
    }
    
    func configure(with model: TermsModel) {
        iconImageView.image = UIImage(systemName: model.icon)
        titleLabel.text = model.title
        descriptionLabel.text = model.content
    }
}
