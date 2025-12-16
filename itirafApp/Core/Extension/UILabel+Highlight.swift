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
    
    func indexOfAttributedTextCharacterAtPoint(point: CGPoint) -> Int {
        guard let attributedString = self.attributedText else { return -1 }
        
        let textStorage = NSTextStorage(attributedString: attributedString)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(size: self.bounds.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = self.numberOfLines
        textContainer.lineBreakMode = self.lineBreakMode
        layoutManager.addTextContainer(textContainer)
        
        let index = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return index
    }
}
