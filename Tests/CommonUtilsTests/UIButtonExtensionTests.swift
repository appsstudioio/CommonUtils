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

    @MainActor
    func test_alignTextBelow_withAttributedTitle_preservesAppearanceAndSpacing() throws {
        let button = UIButton(type: .custom)
        let font = UIFont.systemFont(ofSize: 16)
        let title = NSAttributedString(string: "메뉴", attributes: [.font: font, .foregroundColor: UIColor.gray])
        button.setImage(makeImage(), for: .normal)
        button.setAttributedTitle(title, for: .normal)

        button.alignTextBelow(spacing: 8)

        try assertVerticalLayout(button, spacing: 8)
        XCTAssertEqual(button.currentAttributedTitle, title)
        let displayedTitle = try XCTUnwrap(button.titleLabel?.attributedText)
        XCTAssertEqual(displayedTitle.attribute(.font, at: 0, effectiveRange: nil) as? UIFont, font)
        XCTAssertEqual(displayedTitle.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor, .gray)
    }

    @MainActor
    func test_alignTextBelow_withPlainTitle_preservesFontColorStateAndAction() throws {
        let button = UIButton(type: .custom)
        let font = UIFont.boldSystemFont(ofSize: 14)
        button.titleLabel?.font = font
        button.setTitle("메뉴", for: .normal)
        button.setTitle("선택", for: .selected)
        button.setTitleColor(.red, for: .normal)
        button.setTitleColor(.orange, for: .selected)
        button.setImage(makeImage(), for: .normal)
        var actionCount = 0
        button.addAction(UIAction { _ in actionCount += 1 }, for: .touchUpInside)

        button.alignTextBelow()

        try assertVerticalLayout(button, spacing: 4)
        XCTAssertEqual(button.titleLabel?.font, font)
        XCTAssertEqual(displayedTitleColor(button), .red)
        button.isSelected = true
        try assertVerticalLayout(button, spacing: 4)
        XCTAssertEqual(button.currentTitle, "선택")
        XCTAssertEqual(button.titleLabel?.font, font)
        XCTAssertEqual(displayedTitleColor(button), .orange)
        button.sendActions(for: .touchUpInside)
        XCTAssertEqual(actionCount, 1)
    }

    @MainActor
    func test_alignTextBelow_withExistingConfiguration_preservesOtherSettings() throws {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "메뉴"
        configuration.subtitle = "설명"
        configuration.image = makeImage()
        configuration.baseForegroundColor = .white
        configuration.baseBackgroundColor = .blue
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 12, bottom: 14, trailing: 16)
        configuration.cornerStyle = .large
        let font = UIFont.boldSystemFont(ofSize: 18)
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var attributes = attributes
            attributes.font = font
            return attributes
        }
        let button = UIButton(configuration: configuration)

        button.alignTextBelow(spacing: 6)

        try assertVerticalLayout(button, spacing: 6)
        let updated = try XCTUnwrap(button.configuration)
        XCTAssertEqual(updated.subtitle, configuration.subtitle)
        XCTAssertEqual(updated.baseForegroundColor, configuration.baseForegroundColor)
        XCTAssertEqual(updated.baseBackgroundColor, configuration.baseBackgroundColor)
        XCTAssertEqual(updated.contentInsets, configuration.contentInsets)
        XCTAssertEqual(updated.cornerStyle, configuration.cornerStyle)
        XCTAssertEqual(button.titleLabel?.font, font)
    }

    @MainActor
    func test_alignTextBelow_withoutImageOrTitle_keepsConfigurationUnchanged() {
        let titleOnly = UIButton(type: .custom)
        titleOnly.setTitle("메뉴", for: .normal)
        titleOnly.alignTextBelow()
        XCTAssertNil(titleOnly.configuration)

        let imageOnly = UIButton(type: .custom)
        imageOnly.setImage(makeImage(), for: .normal)
        imageOnly.alignTextBelow()
        XCTAssertNil(imageOnly.configuration)
    }

    @MainActor
    private func makeImage() -> UIImage {
        let size = CGSize(width: 24, height: 24)
        return UIGraphicsImageRenderer(size: size).image { context in
            UIColor.blue.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }.withRenderingMode(.alwaysOriginal)
    }

    @MainActor
    private func assertVerticalLayout(_ button: UIButton, spacing: CGFloat,
                                      file: StaticString = #filePath, line: UInt = #line) throws {
        button.frame = CGRect(x: 0, y: 0, width: 160, height: 160)
        button.setNeedsLayout()
        button.layoutIfNeeded()
        let imageView = try XCTUnwrap(button.imageView, file: file, line: line)
        let titleLabel = try XCTUnwrap(button.titleLabel, file: file, line: line)
        let imageFrame = button.convert(imageView.bounds, from: imageView)
        let titleFrame = button.convert(titleLabel.bounds, from: titleLabel)
        XCTAssertGreaterThan(imageFrame.height, 0, file: file, line: line)
        XCTAssertGreaterThan(titleFrame.height, 0, file: file, line: line)
        XCTAssertEqual(titleFrame.minY - imageFrame.maxY, spacing, accuracy: 0.5, file: file, line: line)
        XCTAssertEqual(titleFrame.midX, imageFrame.midX, accuracy: 0.5, file: file, line: line)
    }

    @MainActor
    private func displayedTitleColor(_ button: UIButton) -> UIColor? {
        guard let attributedTitle = button.titleLabel?.attributedText, attributedTitle.length > 0 else {
            return button.titleLabel?.textColor
        }
        return attributedTitle.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor
    }

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
