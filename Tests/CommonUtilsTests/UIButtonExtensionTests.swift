//
// UIButtonExtensionTests.swift
// CommonUtils
//
// Created by Codex on 2026/03/04.
//

import XCTest
import UIKit
@testable import CommonUtils

final class UIButtonExtensionTests: XCTestCase {

    func test_underlineText_withEmojiTitle_shouldApplyAttributeAcrossUTF16Range() throws {
        let button = UIButton(type: .system)
        let title = "👨‍👩‍👧‍👦테스트"
        button.setTitle(title, for: .normal)

        button.underlineText(titleColor: .red, font: .systemFont(ofSize: 14))

        guard let attributed = button.attributedTitle(for: .normal) else {
            XCTFail("Attributed title should be set")
            return
        }

        let emojiRange = (title as NSString).range(of: "👨‍👩‍👧‍👦")
        XCTAssertNotEqual(emojiRange.location, NSNotFound)

        let startStyle = attributed.attribute(.underlineStyle, at: emojiRange.location, effectiveRange: nil) as? Int
        let endStyle = attributed.attribute(.underlineStyle, at: emojiRange.location + emojiRange.length - 1, effectiveRange: nil) as? Int

        XCTAssertEqual(startStyle, NSUnderlineStyle.single.rawValue)
        XCTAssertEqual(endStyle, NSUnderlineStyle.single.rawValue)
    }
}
