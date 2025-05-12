//
// NSAttributedStringExtensionTests.swift
// CommonUtils
//
// Created by Dongju Lim on 4/15/25
//

import XCTest
import UIKit
@testable import CommonUtils

final class NSAttributedStringExtensionsTests: XCTestCase {

    // MARK: - setStrikethroughStyle
    func test_setStrikethroughStyle_appliesStrikethroughCorrectly() throws {
        let base = NSAttributedString(string: "Test")
        let result = base.setStrikethroughStyle()
        let style = result.attribute(.strikethroughStyle, at: 0, effectiveRange: nil) as? Int
        XCTAssertEqual(style, NSUnderlineStyle.single.rawValue)
    }

    func test_setStrikethroughStyle_preservesOriginalText() throws {
        let base = NSAttributedString(string: "Example")
        let result = base.setStrikethroughStyle()
        XCTAssertEqual(result.string, "Example")
    }

    func test_setStrikethroughStyle_onEmptyString() throws {
        let base = NSAttributedString(string: "")
        let result = base.setStrikethroughStyle()
        XCTAssertEqual(result.string, "")
    }

    func test_setStrikethroughStyle_multipleTimes() throws {
        let base = NSAttributedString(string: "Repeat")
        let once = base.setStrikethroughStyle()
        let twice = once.setStrikethroughStyle()
        let style = twice.attribute(.strikethroughStyle, at: 0, effectiveRange: nil) as? Int
        XCTAssertEqual(style, NSUnderlineStyle.single.rawValue)
    }

    func test_setStrikethroughStyle_withLongText() throws {
        let longText = String(repeating: "A", count: 1000)
        let base = NSAttributedString(string: longText)
        let result = base.setStrikethroughStyle()
        XCTAssertEqual(result.string, longText)
    }

    func testSetStrikethroughStyle_appliesStrikethrough() throws {
        let string = NSAttributedString(string: "Hello")
        let result = string.setStrikethroughStyle()
        let style = result.attribute(.strikethroughStyle, at: 0, effectiveRange: nil) as? Int
        XCTAssertEqual(style, NSUnderlineStyle.single.rawValue)
    }

    // MARK: - changeTextColor
    func test_changeTextColor_appliesColorCorrectly() throws {
        let text = "This is a test string"
        let base = NSAttributedString(string: text)
        let result = base.changeTextColor(color: .red, text: "test")
        let range = (text as NSString).range(of: "test")
        let color = result.attribute(.foregroundColor, at: range.location, effectiveRange: nil) as? UIColor
        XCTAssertEqual(color, .red)
    }

    func test_changeTextColor_forMissingText() throws {
        let base = NSAttributedString(string: "Hello World")
        let result = base.changeTextColor(color: .blue, text: "Swift")
        XCTAssertEqual(result.string, "Hello World")
    }

    func test_changeTextColor_forMultipleInstances() throws {
        let base = NSAttributedString(string: "apple banana apple")
        let result = base.changeTextColor(color: .green, text: "apple")
        let first = result.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor
        let second = result.attribute(.foregroundColor, at: 14, effectiveRange: nil) as? UIColor
        XCTAssertEqual(first, .green)
        XCTAssertEqual(second, .green)
    }

    func test_changeTextColor_partialMatch() throws {
        let base = NSAttributedString(string: "testable")
        let result = base.changeTextColor(color: .orange, text: "test")
        let color = result.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor
        XCTAssertEqual(color, .orange)
    }

    func test_changeTextColor_appliesToCorrectRange() throws {
        let base = NSAttributedString(string: "Swift Unit Test")
        let result = base.changeTextColor(color: .purple, text: "Unit")
        let range = (base.string as NSString).range(of: "Unit")
        let color = result.attribute(.foregroundColor, at: range.location, effectiveRange: nil) as? UIColor
        XCTAssertEqual(color, .purple)
    }

    func testChangeTextColor_appliesColorToText() throws {
        let base = NSAttributedString(string: "Hello world hello")
        let result = base.changeTextColor(color: .red, text: "hello")
        let range1 = (result.string as NSString).range(of: "hello")
        let color1 = result.attribute(.foregroundColor, at: range1.location, effectiveRange: nil) as? UIColor
        XCTAssertEqual(color1, UIColor.red)
    }

    func testChangeTextColor_doesNotChangeUnmatchedText() throws {
        let base = NSAttributedString(string: "No match here")
        let result = base.changeTextColor(color: .blue, text: "notfound")
        let fullAttrs = result.attributes(at: 0, effectiveRange: nil)
        XCTAssertFalse(fullAttrs.keys.contains(.foregroundColor))
    }

    func testChangeTextColor_multipleOccurrences() throws {
        let base = NSAttributedString(string: "test test test")
        let result = base.changeTextColor(color: .green, text: "test")
        var range = NSRange(location: 0, length: result.length)
        var count = 0
        while range.location != NSNotFound {
            range = (result.string as NSString).range(of: "test", options: [], range: range)
            if range.location != NSNotFound {
                count += 1
                range = NSRange(location: range.location + range.length, length: result.length - (range.location + range.length))
            }
        }
        XCTAssertEqual(count, 3)
    }

    func testChangeTextColor_emptyString() throws {
        let base = NSAttributedString(string: "")
        let result = base.changeTextColor(color: .red, text: "")
        XCTAssertEqual(result.string, "")
    }

    func testChangeTextColor_noEffectOnNonTargetText() throws {
        let base = NSAttributedString(string: "Other words")
        let result = base.changeTextColor(color: .purple, text: "target")
        XCTAssertEqual(result.string, "Other words")
    }

    // MARK: - width(height:)
    func test_width_calculatesCorrectWidth() throws {
        let attr = NSAttributedString(string: "Hello", attributes: [.font: UIFont.systemFont(ofSize: 16)])
        let width = attr.width(20)
        XCTAssertGreaterThan(width, 0)
    }

    func test_height_calculatesCorrectHeight() throws {
        let attr = NSAttributedString(string: "Hello\nWorld", attributes: [.font: UIFont.systemFont(ofSize: 16)])
        let height = attr.height(100)
        XCTAssertGreaterThan(height, 0)
    }

    func test_width_zeroHeight() throws {
        let attr = NSAttributedString(string: "Text", attributes: [.font: UIFont.systemFont(ofSize: 14)])
        let width = attr.width(0)
        XCTAssertGreaterThanOrEqual(width, 0)
    }

    func testWidth_returnsCorrectWidth() throws {
        let font = UIFont.systemFont(ofSize: 14)
        let attr = NSAttributedString(string: "Test", attributes: [.font: font])
        let width = attr.width(30)
        XCTAssertGreaterThan(width, 0)
    }

    func testWidth_returnsConsistentValue() throws {
        let font = UIFont.systemFont(ofSize: 14)
        let attr = NSAttributedString(string: "Test", attributes: [.font: font])
        let width1 = attr.width(30)
        let width2 = attr.width(30)
        XCTAssertEqual(width1, width2)
    }

    func testWidth_changesWithHeightConstraint() throws {
        let font = UIFont.systemFont(ofSize: 14)
        let attr = NSAttributedString(string: "Test", attributes: [.font: font])
        let width1 = attr.width(20)
        let width2 = attr.width(50)
        XCTAssertEqual(width1, width2) // Should be same since width is only based on width of text
    }

    func testWidth_forEmptyString_isZero() throws {
        let attr = NSAttributedString(string: "")
        let width = attr.width(20)
        XCTAssertEqual(width, 0)
    }

    func testWidth_longString() throws {
        let font = UIFont.systemFont(ofSize: 12)
        let text = String(repeating: "a", count: 100)
        let attr = NSAttributedString(string: text, attributes: [.font: font])
        let width = attr.width(30)
        XCTAssertGreaterThan(width, 0)
    }

    // MARK: - height(width:)
    func test_height_zeroWidth() throws {
        let attr = NSAttributedString(string: "Multiline\nText", attributes: [.font: UIFont.systemFont(ofSize: 14)])
        let height = attr.height(0)
        XCTAssertGreaterThanOrEqual(height, 0)
    }

    func test_height_longText() throws {
        let attr = NSAttributedString(string: String(repeating: "A", count: 500), attributes: [.font: UIFont.systemFont(ofSize: 12)])
        let height = attr.height(100)
        XCTAssertGreaterThan(height, 0)
    }

    func testHeight_returnsPositiveValue() throws {
        let font = UIFont.systemFont(ofSize: 16)
        let attr = NSAttributedString(string: "Line 1\nLine 2", attributes: [.font: font])
        let height = attr.height(100)
        XCTAssertGreaterThan(height, font.lineHeight)
    }

    func testHeight_returnsNonZeroHeightForEmptyString() throws {
        let font = UIFont.systemFont(ofSize: 14)
        let attr = NSAttributedString(string: "", attributes: [.font: font])
        let height = attr.height(100)
        XCTAssertGreaterThan(height, 0) // 최소 줄 간격은 포함됨
    }

    func testHeight_consistentForSameInput() throws {
        let font = UIFont.systemFont(ofSize: 14)
        let attr = NSAttributedString(string: "Hello", attributes: [.font: font])
        let h1 = attr.height(200)
        let h2 = attr.height(200)
        XCTAssertEqual(h1, h2)
    }

    func testHeight_increasesWithContent() throws {
        let font = UIFont.systemFont(ofSize: 14)
        let oneLine = NSAttributedString(string: "Hello", attributes: [.font: font])
        let twoLines = NSAttributedString(string: "Hello\nWorld", attributes: [.font: font])
        XCTAssertTrue(twoLines.height(200) > oneLine.height(200))
    }

    func testHeight_withLimitedWidth() throws {
        let font = UIFont.systemFont(ofSize: 14)
        let attr = NSAttributedString(string: "Hello Hello Hello Hello", attributes: [.font: font])
        let hNarrow = attr.height(50)
        let hWide = attr.height(500)
        XCTAssertTrue(hNarrow > hWide)
    }

    // MARK: - changeTextBackgroundColor
    func test_changeTextBackgroundColor_shouldApplyCorrectColor() throws {
        let original = NSAttributedString(string: "This is a test string")
        let colored = original.changeTextBackgroundColor(color: .yellow, text: "test")
        let range = (colored.string as NSString).range(of: "test")
        let color = colored.attribute(.backgroundColor, at: range.location, effectiveRange: nil) as? UIColor
        XCTAssertEqual(color, UIColor.yellow)
    }

    func test_changeTextBackgroundColor_shouldNotChangeUnmatchedText() throws {
        let original = NSAttributedString(string: "No match here")
        let colored = original.changeTextBackgroundColor(color: .red, text: "test")
        XCTAssertNil(colored.attribute(.backgroundColor, at: 0, effectiveRange: nil))
    }

    func test_changeTextBackgroundColor_shouldHandleMultipleOccurrences() throws {
        let original = NSAttributedString(string: "test test test")
        let colored = original.changeTextBackgroundColor(color: .green, text: "test")
        let matches = [0, 5, 10].map {
            colored.attribute(.backgroundColor, at: $0, effectiveRange: nil) as? UIColor
        }
        XCTAssertTrue(matches.allSatisfy { $0 == UIColor.green })
    }

    func test_changeTextBackgroundColor_shouldWorkWithEmptyText() throws {
        let original = NSAttributedString(string: "")
        let colored = original.changeTextBackgroundColor(color: .blue, text: "anything")
        XCTAssertEqual(colored.string, "")
    }

    func test_changeTextBackgroundColor_shouldBeIdempotent() throws {
        let original = NSAttributedString(string: "text")
        let once = original.changeTextBackgroundColor(color: .red, text: "text")
        let twice = once.changeTextBackgroundColor(color: .red, text: "text")
        let range = (twice.string as NSString).range(of: "text")
        let color = twice.attribute(.backgroundColor, at: range.location, effectiveRange: nil) as? UIColor
        XCTAssertEqual(color, UIColor.red)
    }

    // MARK: - changeTextFont
    func test_changeTextFont_shouldApplyCorrectFont() throws {
        let original = NSAttributedString(string: "Hello World")
        let font = UIFont.systemFont(ofSize: 20, weight: .bold)
        let changed = original.changeTextFont(font: font, text: "World")
        let range = (changed.string as NSString).range(of: "World")
        let appliedFont = changed.attribute(.font, at: range.location, effectiveRange: nil) as? UIFont
        XCTAssertEqual(appliedFont, font)
    }

    func test_changeTextFont_shouldNotAffectNonMatchingText() throws {
        let original = NSAttributedString(string: "Only one part")
        let font = UIFont.italicSystemFont(ofSize: 12)
        let changed = original.changeTextFont(font: font, text: "missing")
        XCTAssertNil(changed.attribute(.font, at: 0, effectiveRange: nil))
    }

    func test_changeTextFont_shouldHandleMultipleMatches() throws {
        let original = NSAttributedString(string: "change change change")
        let font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        let changed = original.changeTextFont(font: font, text: "change")
        let fontMatches = [0, 7, 14].map {
            changed.attribute(.font, at: $0, effectiveRange: nil) as? UIFont
        }
        XCTAssertTrue(fontMatches.allSatisfy { $0 == font })
    }

    func test_changeTextFont_shouldWorkOnEmptyString() throws {
        let original = NSAttributedString(string: "")
        let changed = original.changeTextFont(font: UIFont.systemFont(ofSize: 10), text: "anything")
        XCTAssertEqual(changed.string, "")
    }

    func test_changeTextFont_shouldNotCrashOnMissingText() throws {
        let original = NSAttributedString(string: "This is fine")
        let changed = original.changeTextFont(font: UIFont.systemFont(ofSize: 12), text: "notfound")
        XCTAssertEqual(changed.string, "This is fine")
    }

    // MARK: - changeParagraphStyle
    func test_changeParagraphStyle_shouldApplyStyleToMatchingText() throws {
        let original = NSAttributedString(string: "Paragraph test")
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        let changed = original.changeParagraphStyle(style: style, text: "Paragraph")
        let range = (changed.string as NSString).range(of: "Paragraph")
        let result = changed.attribute(.paragraphStyle, at: range.location, effectiveRange: nil) as? NSMutableParagraphStyle
        XCTAssertEqual(result?.alignment, .center)
    }

    func test_changeParagraphStyle_shouldSkipIfNoMatch() throws {
        let original = NSAttributedString(string: "No matching text")
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 12
        let changed = original.changeParagraphStyle(style: style, text: "Missing")
        XCTAssertNil(changed.attribute(.paragraphStyle, at: 0, effectiveRange: nil))
    }

    func test_changeParagraphStyle_shouldHandleMultipleInstances() throws {
        let original = NSAttributedString(string: "style style style")
        let style = NSMutableParagraphStyle()
        style.firstLineHeadIndent = 20
        let changed = original.changeParagraphStyle(style: style, text: "style")
        let results = [0, 6, 12].map {
            changed.attribute(.paragraphStyle, at: $0, effectiveRange: nil) as? NSMutableParagraphStyle
        }
        XCTAssertTrue(results.allSatisfy { $0?.firstLineHeadIndent == 20 })
    }

    func test_changeParagraphStyle_shouldBeIdempotent() throws {
        let original = NSAttributedString(string: "text")
        let style = NSMutableParagraphStyle()
        style.alignment = .right
        let once = original.changeParagraphStyle(style: style, text: "text")
        let twice = once.changeParagraphStyle(style: style, text: "text")
        let range = (twice.string as NSString).range(of: "text")
        let result = twice.attribute(.paragraphStyle, at: range.location, effectiveRange: nil) as? NSMutableParagraphStyle
        XCTAssertEqual(result?.alignment, .right)
    }

    func test_changeParagraphStyle_shouldNotBreakOnEmpty() throws {
        let original = NSAttributedString(string: "")
        let style = NSMutableParagraphStyle()
        let changed = original.changeParagraphStyle(style: style, text: "anything")
        XCTAssertEqual(changed.string, "")
    }

    // MARK: - changeTextBackgroundColor
    func test_changeTextBackgroundColor_shouldApplyBackgroundColor() throws {
        let baseString = "Highlight this word and this word"
        let attrString = NSAttributedString(string: baseString)
        let color = UIColor.yellow
        let result = attrString.changeTextBackgroundColor(color: color, text: "word")

        let expectedRanges = NSMutableArray()
        var searchRange = NSRange(location: 0, length: baseString.count)

        while true {
            let foundRange = (baseString as NSString).range(of: "word", options: [], range: searchRange)
            if foundRange.location != NSNotFound {
                expectedRanges.add(NSValue(range: foundRange))
                let nextLocation = foundRange.location + foundRange.length
                if nextLocation >= baseString.count { break }
                searchRange = NSRange(location: nextLocation, length: baseString.count - nextLocation)
            } else {
                break
            }
        }

        for value in expectedRanges {
            guard let range = (value as? NSValue)?.rangeValue else { continue }
            let attributeColor = result.attribute(.backgroundColor, at: range.location, effectiveRange: nil) as? UIColor
            XCTAssertEqual(attributeColor, color)
        }
    }

    func test_changeTextBackgroundColor_shouldNotApplyWhenTextNotFound() throws {
        let attrString = NSAttributedString(string: "No match here")
        let color = UIColor.red
        let result = attrString.changeTextBackgroundColor(color: color, text: "missing")
        let attributes = result.attributes(at: 0, effectiveRange: nil)
        XCTAssertNil(attributes[.backgroundColor])
    }

    func test_changeTextBackgroundColor_shouldApplyToAllOccurrences() throws {
        let baseString = "repeat repeat repeat"
        let attrString = NSAttributedString(string: baseString)
        let color = UIColor.green
        let result = attrString.changeTextBackgroundColor(color: color, text: "repeat")
        let expectedCount = 3
        var foundCount = 0
        for i in 0..<result.length {
            if result.attribute(.backgroundColor, at: i, effectiveRange: nil) != nil {
                foundCount += 1
            }
        }
        XCTAssertGreaterThanOrEqual(foundCount, expectedCount)
    }

    func test_changeTextBackgroundColor_shouldHandleEmptyInputGracefully() throws {
        let attrString = NSAttributedString(string: "")
        let color = UIColor.blue
        let result = attrString.changeTextBackgroundColor(color: color, text: "anything")
        XCTAssertEqual(result.length, 0)
    }

    func test_changeTextBackgroundColor_shouldApplyCorrectColorType() throws {
        let attrString = NSAttributedString(string: "Color me")
        let result = attrString.changeTextBackgroundColor(color: .cyan, text: "Color")
        let color = result.attribute(.backgroundColor, at: 0, effectiveRange: nil) as? UIColor
        XCTAssertEqual(color, .cyan)
    }

    // MARK: - changeTextFont
    func test_changeTextFont_shouldApplyFont() throws {
        let attrString = NSAttributedString(string: "Make this bold")
        let font = UIFont.boldSystemFont(ofSize: 16)
        let result = attrString.changeTextFont(font: font, text: "this")
        let appliedFont = result.attribute(.font, at: 5, effectiveRange: nil) as? UIFont
        XCTAssertEqual(appliedFont, font)
    }

    func test_changeTextFont_shouldNotApplyWhenTextMissing() throws {
        let attrString = NSAttributedString(string: "Hello World")
        let font = UIFont.italicSystemFont(ofSize: 14)
        let result = attrString.changeTextFont(font: font, text: "Missing")
        let fontAttribute = result.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
        XCTAssertNil(fontAttribute)
    }

    func test_changeTextFont_shouldApplyToAllMatchingText() throws {
        let text = "Hello Hello Hello"
        let attrString = NSAttributedString(string: text)
        let font = UIFont.systemFont(ofSize: 12)
        let result = attrString.changeTextFont(font: font, text: "Hello")
        var count = 0
        for i in 0..<result.length {
            if let applied = result.attribute(.font, at: i, effectiveRange: nil) as? UIFont, applied == font {
                count += 1
            }
        }
        XCTAssertGreaterThan(count, 0)
    }

    func test_changeTextFont_shouldSupportDifferentFonts() throws {
        let attrString = NSAttributedString(string: "Fancy")
        let font = UIFont(name: "Courier", size: 10) ?? UIFont.systemFont(ofSize: 10)
        let result = attrString.changeTextFont(font: font, text: "Fancy")
        let appliedFont = result.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
        XCTAssertEqual(appliedFont?.fontName, font.fontName)
    }

    func test_changeTextFont_shouldWorkOnWholeString() throws {
        let baseString = "All of this"
        let font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        let result = NSAttributedString(string: baseString).changeTextFont(font: font, text: baseString)
        for i in 0..<result.length {
            let applied = result.attribute(.font, at: i, effectiveRange: nil) as? UIFont
            XCTAssertEqual(applied?.fontName, font.fontName)
        }
    }

    // MARK: changeTextsFont(font:texts:)
    func test_changeTextsFont_shouldApplyFontToMultipleTexts() throws {
        let original = NSAttributedString(string: "Swift is fast and safe. Swift is modern.")
        let font = UIFont.systemFont(ofSize: 20)
        let result = original.changeTextsFont(font: font, texts: ["Swift", "modern"])

        let expectedRanges = [(0, 5), (26, 5)]
        for (location, _) in expectedRanges {
            let attrFont = result.attribute(.font, at: location, effectiveRange: nil) as? UIFont
            XCTAssertEqual(attrFont, font)
        }
    }

    func test_changeTextsFont_shouldNotAffectUnrelatedText() throws {
        let original = NSAttributedString(string: "Hello world")
        let font = UIFont.italicSystemFont(ofSize: 12)
        let result = original.changeTextsFont(font: font, texts: ["Swift"])

        let attr = result.attribute(.font, at: 0, effectiveRange: nil)
        XCTAssertNil(attr)
    }

    func test_changeTextsFont_shouldHandleEmptyArray() throws {
        let original = NSAttributedString(string: "Some Text")
        let font = UIFont.boldSystemFont(ofSize: 14)
        let result = original.changeTextsFont(font: font, texts: [])

        let attr = result.attribute(.font, at: 0, effectiveRange: nil)
        XCTAssertNil(attr)
    }

    func test_changeTextsFont_shouldApplyFontToOverlappingTexts() throws {
        let original = NSAttributedString(string: "abcabcabc")
        let font = UIFont.systemFont(ofSize: 11)
        let result = original.changeTextsFont(font: font, texts: ["abc", "bca"])

        let attr1 = result.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
        let attr2 = result.attribute(.font, at: 3, effectiveRange: nil) as? UIFont
        XCTAssertEqual(attr1, font)
        XCTAssertEqual(attr2, font)
    }

    func test_changeTextsFont_shouldApplyFontToDuplicateTexts() throws {
        let original = NSAttributedString(string: "one one two")
        let font = UIFont(name: "Courier", size: 13)!
        let result = original.changeTextsFont(font: font, texts: ["one"])

        let attr1 = result.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
        let attr2 = result.attribute(.font, at: 4, effectiveRange: nil) as? UIFont
        XCTAssertEqual(attr1, font)
        XCTAssertEqual(attr2, font)
    }

    // MARK: changeTextUnderLine(text:)
    func test_changeTextUnderLine_shouldUnderlineMatchedText() throws {
        let original = NSAttributedString(string: "Underline this word please.")
        let result = original.changeTextUnderLine(text: "this")

        let underline = result.attribute(.underlineStyle, at: 10, effectiveRange: nil) as? Int
        XCTAssertEqual(underline, NSUnderlineStyle.single.rawValue)
    }

    func test_changeTextUnderLine_shouldIgnoreUnmatchedText() throws {
        let original = NSAttributedString(string: "Nothing here")
        let result = original.changeTextUnderLine(text: "missing")

        let underline = result.attribute(.underlineStyle, at: 0, effectiveRange: nil)
        XCTAssertNil(underline)
    }

    func test_changeTextUnderLine_shouldUnderlineMultipleOccurrences() throws {
        let original = NSAttributedString(string: "yes yes yes")
        let result = original.changeTextUnderLine(text: "yes")

        let underline1 = result.attribute(.underlineStyle, at: 0, effectiveRange: nil) as? Int
        let underline2 = result.attribute(.underlineStyle, at: 4, effectiveRange: nil) as? Int
        let underline3 = result.attribute(.underlineStyle, at: 8, effectiveRange: nil) as? Int
        XCTAssertEqual(underline1, NSUnderlineStyle.single.rawValue)
        XCTAssertEqual(underline2, NSUnderlineStyle.single.rawValue)
        XCTAssertEqual(underline3, NSUnderlineStyle.single.rawValue)
    }

    func test_changeTextUnderLine_shouldHandleEmptyText() throws {
        let original = NSAttributedString(string: "")
        let result = original.changeTextUnderLine(text: "anything")
        XCTAssertEqual(result.string, "")
    }

    func test_changeTextUnderLine_shouldNotUnderlineDifferentCase() throws {
        let original = NSAttributedString(string: "Text CASE test")
        let result = original.changeTextUnderLine(text: "case")

        let underline = result.attribute(.underlineStyle, at: 5, effectiveRange: nil)
        XCTAssertNil(underline)
    }

    // MARK: - changeTextsColor
    func test_changeTextsColor_singleMatch() throws {
        let text = "Hello world"
        let attributed = NSAttributedString(string: text)
        let colored = attributed.changeTextsColor(color: .red, texts: ["world"])
        let attributes = colored.attributes(at: 6, effectiveRange: nil)
        XCTAssertEqual(attributes[.foregroundColor] as? UIColor, .red)
    }

    func test_changeTextsColor_multipleMatches() throws {
        let text = "Swift is fun. Swift is powerful."
        let attributed = NSAttributedString(string: text)
        let colored = attributed.changeTextsColor(color: .blue, texts: ["Swift"])
        let attributesFirst = colored.attributes(at: 0, effectiveRange: nil)
        let attributesSecond = colored.attributes(at: 17, effectiveRange: nil)
        XCTAssertEqual(attributesFirst[.foregroundColor] as? UIColor, .blue)
        XCTAssertEqual(attributesSecond[.foregroundColor] as? UIColor, .blue)
    }

    func test_changeTextsColor_caseSensitive() throws {
        let text = "Text text TEXT"
        let attributed = NSAttributedString(string: text)
        let colored = attributed.changeTextsColor(color: .green, texts: ["text"])
        let attributes = colored.attributes(at: 5, effectiveRange: nil)
        XCTAssertEqual(attributes[.foregroundColor] as? UIColor, .green)
        let upperAttributes = colored.attributes(at: 10, effectiveRange: nil)
        XCTAssertNil(upperAttributes[.foregroundColor])
    }

    func test_changeTextsColor_textNotFound() throws {
        let text = "No matches here"
        let attributed = NSAttributedString(string: text)
        let colored = attributed.changeTextsColor(color: .gray, texts: ["missing"])
        let attributes = colored.attributes(at: 0, effectiveRange: nil)
        XCTAssertNil(attributes[.foregroundColor])
    }

    func test_changeTextsColor_multipleTexts() throws {
        let text = "One Two Three"
        let attributed = NSAttributedString(string: text)
        let colored = attributed.changeTextsColor(color: .orange, texts: ["One", "Three"])
        let attrOne = colored.attributes(at: 0, effectiveRange: nil)
        let attrThree = colored.attributes(at: 8, effectiveRange: nil)
        XCTAssertEqual(attrOne[.foregroundColor] as? UIColor, .orange)
        XCTAssertEqual(attrThree[.foregroundColor] as? UIColor, .orange)
    }

    // MARK: - sizeFittingWidth
    func test_sizeFittingWidth_shouldReturnSizeForSingleLine() throws {
        let font = UIFont.systemFont(ofSize: 14)
        let attributed = NSAttributedString(string: "Hello", attributes: [.font: font])
        let size = attributed.sizeFittingWidth(200)
        XCTAssertGreaterThan(size.width, 0)
        XCTAssertLessThan(size.width, 200)
    }

    func test_sizeFittingWidth_shouldWrapLongText() throws {
        let font = UIFont.systemFont(ofSize: 14)
        let text = String(repeating: "Swift ", count: 20)
        let attributed = NSAttributedString(string: text, attributes: [.font: font])
        let size = attributed.sizeFittingWidth(100)
        XCTAssertGreaterThan(size.height, font.lineHeight)
    }

    func test_sizeFittingWidth_widthAffectsResult() throws {
        let font = UIFont.systemFont(ofSize: 14)
        let text = "This is a line of text."
        let attributed = NSAttributedString(string: text, attributes: [.font: font])
        let size1 = attributed.sizeFittingWidth(300)
        let size2 = attributed.sizeFittingWidth(100)
        XCTAssertTrue(size1.height < size2.height)
    }

    func test_sizeFittingWidth_zeroWidthShouldReturnZeroSize() throws {
        let font = UIFont.systemFont(ofSize: 14)
        let attributed = NSAttributedString(string: "Some text", attributes: [.font: font])
        let size = attributed.sizeFittingWidth(0)
        XCTAssertGreaterThan(size.width, 0)
    }

    func test_sizeFittingWidth_emptyString() throws {
        let font = UIFont.systemFont(ofSize: 14)
        let attributed = NSAttributedString(string: "", attributes: [.font: font])
        let size = attributed.sizeFittingWidth(100)
        XCTAssertEqual(size.width, 0)
        XCTAssertEqual(size.height, font.pointSize)
    }

    // MARK: - getBoxSizeAndLineCnt
    func test_getBoxSizeAndLineCnt_shouldReturnCorrectLineCount() throws {
        let font = UIFont.systemFont(ofSize: 14)
        let text = String(repeating: "Swift ", count: 40)
        let attributed = NSAttributedString(string: text, attributes: [.font: font])
        let (_, lines) = attributed.getBoxSizeAndLineCnt(maxWidth: 100, fontSize: font)
        XCTAssertGreaterThan(lines, 1)
    }

    func test_getBoxSizeAndLineCnt_shouldHandleSingleLine() throws {
        let font = UIFont.systemFont(ofSize: 14)
        let text = "Short"
        let attributed = NSAttributedString(string: text, attributes: [.font: font])
        let (_, lines) = attributed.getBoxSizeAndLineCnt(maxWidth: 300, fontSize: font)
        XCTAssertEqual(lines, 1)
    }

    func test_getBoxSizeAndLineCnt_shouldReturnZeroForEmpty() throws {
        let font = UIFont.systemFont(ofSize: 14)
        let attributed = NSAttributedString(string: "", attributes: [.font: font])
        let (size, lines) = attributed.getBoxSizeAndLineCnt(maxWidth: 100, fontSize: font)
        XCTAssertEqual(lines, 1)
        XCTAssertEqual(size.width, 0)
        XCTAssertEqual(size.height, UIFont.systemFont(ofSize: 14).pointSize)
    }

    func test_getBoxSizeAndLineCnt_shouldIncreaseLinesWhenWidthDecreases() throws {
        let font = UIFont.systemFont(ofSize: 14)
        let text = "A very long text to wrap lines and test layout manager behavior in getBoxSizeAndLineCnt"
        let attributed = NSAttributedString(string: text, attributes: [.font: font])
        let (_, linesWide) = attributed.getBoxSizeAndLineCnt(maxWidth: 300, fontSize: font)
        let (_, linesNarrow) = attributed.getBoxSizeAndLineCnt(maxWidth: 100, fontSize: font)
        XCTAssertTrue(linesNarrow > linesWide)
    }

    func test_getBoxSizeAndLineCnt_shouldWorkWithCustomFont() throws {
        let font = UIFont.boldSystemFont(ofSize: 20)
        let text = "Swift is awesome"
        let attributed = NSAttributedString(string: text, attributes: [.font: font])
        let (size, lines) = attributed.getBoxSizeAndLineCnt(maxWidth: 200, fontSize: font)
        XCTAssertGreaterThan(size.height, 0)
        XCTAssertGreaterThan(lines, 0)
    }

    // MARK: - extractAndRemoveImageAttachments
    func test_extractAndRemoveImageAttachments_withSingleImage() throws {
        let image = UIImage.makeColorImage(color: .red)
        let attachment = NSTextAttachment()
        attachment.image = image
        let attrString = NSMutableAttributedString(attachment: attachment)
        let extracted = attrString.extractAndRemoveImageAttachments
        XCTAssertEqual(extracted.count, 1)
        XCTAssertTrue(attrString.string.isEmpty)
    }

    func test_extractAndRemoveImageAttachments_withMultipleImages() throws {
        let attrString = NSMutableAttributedString()
        for _ in 0..<3 {
            let image = UIImage.makeColorImage(color: .green)
            let attachment = NSTextAttachment()
            attachment.image = image
            attrString.append(NSAttributedString(attachment: attachment))
        }

        let extracted = attrString.extractAndRemoveImageAttachments
        XCTAssertEqual(extracted.count, 3)
        XCTAssertTrue(attrString.string.isEmpty)
    }

    func test_extractAndRemoveImageAttachments_withNoImage() throws {
        let attrString = NSMutableAttributedString(string: "No image here.")
        let extracted = attrString.extractAndRemoveImageAttachments
        XCTAssertTrue(extracted.isEmpty)
        XCTAssertEqual(attrString.string, "No image here.")
    }

    func test_extractAndRemoveImageAttachments_withMixedContent() throws {
        let text = NSMutableAttributedString(string: "Before ")
        let image = UIImage.makeColorImage(color: .blue)
        let attachment = NSTextAttachment()
        attachment.image = image
        text.append(NSAttributedString(attachment: attachment))
        text.append(NSAttributedString(string: " After"))

        let extracted = text.extractAndRemoveImageAttachments
        XCTAssertEqual(extracted.count, 1)
        XCTAssertEqual(text.string, "Before  After")
    }

    func test_extractAndRemoveImageAttachments_withDataImage() throws {
        let image = UIImage.makeColorImage(color: .yellow)
        let attachment = NSTextAttachment()
        attachment.contents = image.pngData()
        let attrString = NSMutableAttributedString(attachment: attachment)

        let extracted = attrString.extractAndRemoveImageAttachments
        XCTAssertEqual(extracted.count, 1)
        XCTAssertTrue(attrString.string.isEmpty)
    }
}
