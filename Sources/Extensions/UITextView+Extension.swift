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

    // 내 이미지(NSTextAttachment) 직접 추출하는 함수
    var extractImagesFromAttachments: [UIImage] {
        var extractedImages: [UIImage] = []
        // 원본 복사
        let mutableAttrString = NSMutableAttributedString(attributedString: self.attributedText)
        // 이미지 추출 및 제거
        extractedImages = mutableAttrString.extractAndRemoveImageAttachments
        // UITextView에 적용
        self.attributedText = mutableAttrString
        return extractedImages.reversed() // 원래 순서로
    }

    /// 현재 텍스트뷰의 기본 스타일(typingAttributes 또는 기본 font/textColor 등)을 기준으로 외부 텍스트의 스타일 제거
    func removeAllTextAttributesPreservingTypingStyle() {
        let attributedString = NSMutableAttributedString(attributedString: self.attributedText)

        // 기준 스타일: typingAttributes > 기본 폰트/컬러/정렬/라인높이
        let baseFont = ((self.typingAttributes[.font] as? UIFont ?? self.font) ?? UIFont.systemFont(ofSize: 14))
        let baseColor = ((self.typingAttributes[.foregroundColor] as? UIColor ?? self.textColor) ?? .black)

        let paragraphStyle: NSMutableParagraphStyle = {
            if let style = self.typingAttributes[.paragraphStyle] as? NSMutableParagraphStyle {
                return style
            } else {
                let newStyle = NSMutableParagraphStyle()
                newStyle.alignment = self.textAlignment
                if let lineHeight = self.font?.lineHeight {
                    newStyle.minimumLineHeight = lineHeight
                    newStyle.maximumLineHeight = lineHeight
                }
                return newStyle
            }
        }()

        // 새 스타일로 전체 텍스트 덮어씌우기
        attributedString.enumerateAttributes(in: NSRange(location: 0, length: attributedString.length), options: []) { _, range, _ in
            attributedString.setAttributes([
                .font: baseFont,
                .foregroundColor: baseColor,
                .paragraphStyle: paragraphStyle
            ], range: range)
        }

        self.attributedText = attributedString
    }
}
