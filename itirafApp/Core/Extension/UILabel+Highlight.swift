//
//  UILabel+Highlight.swift
//  itirafApp
//
//  Created by Emre on 13.12.2025.
//

import UIKit

extension UILabel {
    func highlight(targetString: String, color: UIColor) {
        guard let fullText = self.text else { return }

        let range = (fullText as NSString).range(of: targetString)
        
        let attributedString = NSMutableAttributedString(string: fullText)
        attributedString.addAttribute(.foregroundColor, value: color, range: range)
        
        attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 14), range: range)
        
        self.attributedText = attributedString
    }
}
