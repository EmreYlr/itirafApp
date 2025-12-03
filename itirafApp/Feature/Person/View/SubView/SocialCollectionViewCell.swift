//
//  SocialCollectionViewCell.swift
//  itirafApp
//
//  Created by Emre on 30.10.2025.
//

import UIKit

final class SocialCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var platformNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var visibleSwitch: UISwitch!
    
    var onEditButtonTapped: (() -> Void)?
    var onSwitchToggled: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.backgroundColor = .backgroundCard
        bgView.layer.cornerRadius = 6
        iconView.layer.cornerRadius = 8
        iconView.backgroundColor = .backgroundCard
        iconView.clipsToBounds = true
    }
    
    func configure(with link: Link) {
        usernameLabel.text = link.username
        platformNameLabel.text = link.platform.displayName
        iconImageView.image = UIImage(named: link.platform.iconName)
        
        visibleSwitch.isOn = link.visible
        
        let alphaValue: CGFloat = link.visible ? 1.0 : 0.5
        
        self.bgView.alpha = alphaValue
        self.iconView.alpha = alphaValue
        self.platformNameLabel.alpha = alphaValue
        self.usernameLabel.alpha = alphaValue
        self.iconImageView.alpha = alphaValue
    }
    
    private func updateAppearance(isActive: Bool) {
        let alphaValue: CGFloat = isActive ? 1.0 : 0.5
        
        UIView.animate(withDuration: 0.3) {
            self.bgView.alpha = alphaValue
            self.iconView.alpha = alphaValue
            self.platformNameLabel.alpha = alphaValue
            self.usernameLabel.alpha = alphaValue
            self.iconImageView.alpha = alphaValue
        }
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        onEditButtonTapped?()
    }
    
    @IBAction func visibleSwitchChanged(_ sender: UISwitch) {
        updateAppearance(isActive: sender.isOn)
        
        onSwitchToggled?(sender.isOn)
    }
}
