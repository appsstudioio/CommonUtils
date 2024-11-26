//
//  NSAttributedString+Extension.swift
//
//
//  Created by 10-N3344 on 2023/06/14.
//

import Foundation
import UIKit

public extension NSAttributedString {
    func setStrikethroughStyle() -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(attributedString: self)
        attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, self.string.count))
        return attributedString
    }
    
    func changeTextColor(color: UIColor, text: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(attributedString: self)

        var range = NSRange(location: 0, length: self.length)
        while (range.location != NSNotFound) {
            range = (self.string as NSString).range(of: text, options: [], range: range)
            if (range.location != NSNotFound) {
                attributedString.addAttribute(.foregroundColor, value: color, range: NSRange(location: range.location, length: text.count))
                range = NSRange(location: range.location + range.length, length: self.string.count - (range.location + range.length))
            }
        }

        return attributedString
    }
    
    func changeTextBackgroundColor(color: UIColor, text: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(attributedString: self)

        var range = NSRange(location: 0, length: self.length)
        while (range.location != NSNotFound) {
            range = (self.string as NSString).range(of: text, options: [], range: range)
            if (range.location != NSNotFound) {
                attributedString.addAttribute(.backgroundColor, value: color, range: NSRange(location: range.location, length: text.count))
                range = NSRange(location: range.location + range.length, length: self.string.count - (range.location + range.length))
            }
        }

        return attributedString
    }

    func changeTextFont(font: UIFont, text: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(attributedString: self)

        var range = NSRange(location: 0, length: self.length)
        while (range.location != NSNotFound) {
            range = (self.string as NSString).range(of: text, options: [], range: range)
            if (range.location != NSNotFound) {
                attributedString.addAttribute(.font, value: font, range: NSRange(location: range.location, length: text.count))
                range = NSRange(location: range.location + range.length, length: self.string.count - (range.location + range.length))
            }
        }

        return attributedString
    }

    func changeParagraphStyle(style: NSMutableParagraphStyle, text: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(attributedString: self)

        var range = NSRange(location: 0, length: self.length)
        while (range.location != NSNotFound) {
            range = (self.string as NSString).range(of: text, options: [], range: range)
            if (range.location != NSNotFound) {
                attributedString.addAttribute(.paragraphStyle, value: style, range: NSRange(location: range.location, length: text.count))
                range = NSRange(location: range.location + range.length, length: self.string.count - (range.location + range.length))
            }
        }

        return attributedString
    }
    
    func changeTextsColor(color: UIColor, texts: [String]) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(attributedString: self)
        
        texts.forEach {
            var range = NSRange(location: 0, length: self.length)
            while (range.location != NSNotFound) {
                range = (self.string as NSString).range(of: $0, options: [], range: range)
                if (range.location != NSNotFound) {
                    attributedString.addAttribute(.foregroundColor, value: color, range: NSRange(location: range.location, length: $0.count))
                    range = NSRange(location: range.location + range.length, length: self.string.count - (range.location + range.length))
                }
            }
        }
        
        return attributedString
    }
    
    func changeTextsFont(font: UIFont, texts: [String]) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(attributedString: self)
        
        texts.forEach {
            var range = NSRange(location: 0, length: self.length)
            while (range.location != NSNotFound) {
                range = (self.string as NSString).range(of: $0, options: [], range: range)
                if (range.location != NSNotFound) {
                    attributedString.addAttribute(.font, value: font, range: NSRange(location: range.location, length: $0.count))
                    range = NSRange(location: range.location + range.length, length: self.string.count - (range.location + range.length))
                }
            }
        }

        return attributedString
    }
    
    func changeTextUnderLine(text: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(attributedString: self)
        
        var range = NSRange(location: 0, length: self.length)
        while (range.location != NSNotFound) {
            range = (self.string as NSString).range(of: text, options: [], range: range)
            if (range.location != NSNotFound) {
                attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: range.location, length: text.count))
                range = NSRange(location: range.location + range.length, length: self.string.count - (range.location + range.length))
            }
        }

        return attributedString
    }
    
    func width(_ height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: [.usesLineFragmentOrigin, .usesFontLeading],
                                            context: nil)
        return ceil(boundingBox.width)
    }

    func height(_ width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: [.usesLineFragmentOrigin, .usesFontLeading],
                                            context: nil)
        return ceil(boundingBox.height)

    }

    // https://stackoverflow.com/questions/54497598/nsattributedstring-boundingrect-returns-wrong-height
    func sizeFittingWidth(_ w: CGFloat) -> CGSize {
        let textStorage = NSTextStorage(attributedString: self)
        let size = CGSize(width: w, height: CGFloat.greatestFiniteMagnitude)
        let boundingRect = CGRect(origin: .zero, size: size)

        let textContainer = NSTextContainer(size: size)
        textContainer.lineFragmentPadding = 0

        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)

        textStorage.addLayoutManager(layoutManager)
        layoutManager.glyphRange(forBoundingRect: boundingRect, in: textContainer)
        let rect = layoutManager.usedRect(for: textContainer)
        return rect.integral.size
    }

    func getBoxSizeAndLineCnt(maxWidth: CGFloat, fontSize: UIFont) -> (CGSize, Int) {
        let size = self.sizeFittingWidth(maxWidth) ?? CGSize(width: maxWidth, height: fontSize.lineHeight)
        let height = size.height
        let lineCnt = Int(lroundf(Float(height / fontSize.lineHeight))) ?? 1
        return (size, lineCnt)
    }
}
