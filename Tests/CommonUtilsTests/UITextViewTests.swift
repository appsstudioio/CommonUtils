//
// UITextViewTests.swift
// CommonUtils
//
// Created by Dongju Lim on 4/30/25
//

import XCTest
import UIKit
@testable import CommonUtils

final class UITextViewTests: XCTestCase {
    // MARK: - textViewSizeForString
    func test_textViewSizeForSingleLine() throws {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.text = "Hello"

        let size = textView.textViewSizeForString(width: 200)
        XCTAssertTrue(size.height > 0)
    }

    func test_textViewSizeForMultiline() throws {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.text = "This is a long line\nthat wraps into multiple lines"

        let size = textView.textViewSizeForString(width: 100)
        XCTAssertTrue(size.height > 30)
    }

    func test_textViewSizeForEmptyText() throws {
        let textView = UITextView()
        textView.text = ""

        let size = textView.textViewSizeForString(width: 150)
        XCTAssertEqual(size, .zero)
    }

    func test_textViewSizeWithCustomLineHeight() throws {
        let textView = UITextView()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 30
        textView.typingAttributes = [.font: UIFont.systemFont(ofSize: 14), .paragraphStyle: paragraphStyle]
        textView.text = "Custom line height"

        let size = textView.textViewSizeForString(width: 200)
        XCTAssertTrue(size.height >= 30)
    }

    func test_textViewSizeWithAttributedText() throws {
        let textView = UITextView()
        let attrString = NSMutableAttributedString(string: "Styled")
        attrString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 18), range: NSRange(location: 0, length: 6))
        textView.attributedText = attrString

        let size = textView.textViewSizeForString(width: 150)
        XCTAssertTrue(size.height > 10)
    }

    // MARK: - extractImagesFromAttachments
    func test_extractImagesFromAttachments_removesAndReturnsImages() throws {
        let textView = UITextView()

        // 1. 테스트 이미지 생성
        let image = UIImage.makeColorImage(color: .blue)
        let attachment = NSTextAttachment()
        attachment.image = image
        let imageAttr = NSAttributedString(attachment: attachment)

        // 2. 이미지 + 텍스트 구성
        let fullAttrText = NSMutableAttributedString(string: "Before ")
        fullAttrText.append(imageAttr)
        fullAttrText.append(NSAttributedString(string: " After"))

        // 3. 텍스트뷰에 적용
        textView.attributedText = fullAttrText

        // 4. 이미지 추출
        let extractedImages = textView.extractImagesFromAttachments

        // 5. 검증
        XCTAssertEqual(extractedImages.count, 1)
        XCTAssertEqual(textView.attributedText.string, "Before  After")
    }

    // MARK: - removeAllTextAttributesPreservingTypingStyle
    func test_removeAllAttributesWithTypingAttributes() throws {
        let textView = UITextView()
        let attributed = NSMutableAttributedString(string: "Styled Text")
        attributed.addAttribute(.font, value: UIFont.italicSystemFont(ofSize: 20), range: NSRange(location: 0, length: 11))
        textView.attributedText = attributed
        textView.typingAttributes = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.red
        ]

        textView.removeAllTextAttributesPreservingTypingStyle()
        let attr = textView.attributedText.attributes(at: 0, effectiveRange: nil)
        XCTAssertEqual(attr[.font] as? UIFont, UIFont.systemFont(ofSize: 14))
        XCTAssertEqual(attr[.foregroundColor] as? UIColor, UIColor.red)
    }

    func test_removeAllAttributesWithoutTypingAttributes() throws {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.textColor = .blue
        textView.text = "Simple"

        textView.removeAllTextAttributesPreservingTypingStyle()
        let attr = textView.attributedText.attributes(at: 0, effectiveRange: nil)
        XCTAssertEqual(attr[.font] as? UIFont, UIFont.systemFont(ofSize: 18))
        XCTAssertEqual(attr[.foregroundColor] as? UIColor, UIColor.blue)
    }

    func test_removeAllAttributesKeepsAlignment() throws {
        let textView = UITextView()
        textView.text = "Aligned"
        textView.textAlignment = .center

        textView.removeAllTextAttributesPreservingTypingStyle()
        let attr = textView.attributedText.attributes(at: 0, effectiveRange: nil)
        let para = attr[.paragraphStyle] as? NSMutableParagraphStyle
        XCTAssertEqual(para?.alignment, .center)
    }

    func test_removeAllAttributesWithLineHeight() throws {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.text = "Line height"

        textView.removeAllTextAttributesPreservingTypingStyle()
        let attr = textView.attributedText.attributes(at: 0, effectiveRange: nil)
        let para = attr[.paragraphStyle] as? NSMutableParagraphStyle
        XCTAssertEqual(para?.minimumLineHeight ?? 0, textView.font?.lineHeight ?? 0, accuracy: 0.5)
    }

    func test_removeAllAttributesOnMixedStyledText() throws {
        let textView = UITextView()
        let attrText = NSMutableAttributedString(string: "Bold and Color")
        attrText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 18), range: NSRange(location: 0, length: 4))
        attrText.addAttribute(.foregroundColor, value: UIColor.green, range: NSRange(location: 9, length: 5))
        textView.attributedText = attrText
        textView.typingAttributes = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.black
        ]

        textView.removeAllTextAttributesPreservingTypingStyle()
        let attrs = textView.attributedText.attributes(at: 0, effectiveRange: nil)
        XCTAssertEqual(attrs[.font] as? UIFont, UIFont.systemFont(ofSize: 14))
    }
}

