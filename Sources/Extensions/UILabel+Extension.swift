//
//  UILabel+Extension.swift
//
//
//  Created by 10-N3344 on 10/10/23.
//

import UIKit

public extension UILabel {
    private var attributes: [NSAttributedString.Key: Any] {
        return self.attributedText?.attributes(at: 0, effectiveRange: nil) ?? [:]
    }
    
    func calculateMaxLines() -> Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        var charSize: CGFloat = 0
        if let font = self.font {
            charSize = font.lineHeight
        } else {
            let font = self.attributes[.font] as? UIFont
            charSize = font?.lineHeight ?? 0
        }

        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize,
                                         options: .usesLineFragmentOrigin,
                                         attributes: [NSAttributedString.Key.font: font as Any],
                                         context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
}
