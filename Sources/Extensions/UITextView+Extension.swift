//
//  UITextView+Extension.swift
//
//
// Created by Dongju Lim on 4/9/24.
//

import Foundation
import UIKit

public extension UITextView {
    func textViewSizeForString(width: CGFloat) -> CGSize {
        let text = self.text ?? ""

        if text.count == 0 {
            return CGSizeZero
        }
        
        var attributes = self.typingAttributes
        if attributes[.paragraphStyle] == nil {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            paragraphStyle.lineBreakMode = .byWordWrapping
            attributes[.paragraphStyle] = paragraphStyle
        }

        if attributes[.font] == nil {
            attributes[.font] = self.font
        }

        let extraWidth = (text as NSString).boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude),
                                                         options: [.usesFontLeading, .usesLineFragmentOrigin],
                                                         attributes: attributes,
                                                         context: nil).size.width

        var size = self.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        size.width = extraWidth

        return size
    }
}
