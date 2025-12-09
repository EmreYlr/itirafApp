//
//  OnboardingCollectionViewCell.swift
//  itirafApp
//
//  Created by Emre on 9.12.2025.
//

import UIKit

final class OnboardingCollectionViewCell: UICollectionViewCell {
    //MARK: -Properties
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var slideImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(with slide: OnboardingSlide) {
        slideImageView.image = UIImage(named: slide.imageName)
        titleLabel.text = slide.title
        descriptionLabel.text = slide.description
    }
}
