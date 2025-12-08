//
//  EmptyStateView.swift
//  itirafApp
//
//  Created by Emre on 8.12.2025.
//

import UIKit

final class EmptyStateView: UIView {
    //MARK: -Properties
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageBgView: UIView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var onButtonAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("EmptyStateView", owner: self, options: nil)
        
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: self.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        setupUI()
    }
    
    private func setupUI() {
        actionButton.layer.cornerRadius = 8
        imageBgView.layer.cornerRadius = imageBgView.frame.width / 2
        imageBgView.clipsToBounds = true
        imageBgView.layer.borderColor = UIColor.textSecondary.cgColor
        imageBgView.layer.borderWidth = 1
        imageView.contentMode = .scaleAspectFit
        titleLabel.numberOfLines = 0
    }
    
    func configure(with type: EmptyStateType, action: (() -> Void)? = nil) {
        let config = UIImage.SymbolConfiguration(pointSize: 60, weight: .regular)
        imageView.image = UIImage(systemName: type.systemImageName, withConfiguration: config)

        titleLabel.text = type.title

        if let btnTitle = type.buttonTitle {
            actionButton.setTitle(btnTitle, for: .normal)
            actionButton.isHidden = false
            self.onButtonAction = action
        } else {
            actionButton.isHidden = true
        }
    }

    @IBAction func actionButtonTapped(_ sender: UIButton) {
        onButtonAction?()
    }
}
