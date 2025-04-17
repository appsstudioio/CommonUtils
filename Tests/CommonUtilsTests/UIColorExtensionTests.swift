//
// UIColorExtensionTests.swift
// CommonUtils
//
// Created by Dongju Lim on 4/16/25
//

import XCTest
import UIKit
@testable import CommonUtils

final class UIColorHexExtensionTests: XCTestCase {

    // MARK: - toHex Tests
    func testToHex_withoutAlpha() throws {
        let color = UIColor(red: 1, green: 0.5, blue: 0, alpha: 1)
        XCTAssertEqual(color.toHex(isAlpha: false), "FF8000")
    }

    func testToHex_withAlpha() throws {
        let color = UIColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 0.8)
        XCTAssertEqual(color.toHex(isAlpha: true), "336699CC")
    }

    func testToHex_blackColor() throws {
        let color = UIColor.black
        XCTAssertEqual(color.toHex(isAlpha: false), "000000")
    }

    func testToHex_whiteColorWithAlpha() throws {
        let color = UIColor.white.withAlphaComponent(0.5)
        XCTAssertEqual(color.toHex(isAlpha: true), "FFFFFF80")
    }

    func testToHex_invalidColorComponents() throws {
        let color = UIColor(patternImage: UIImage()) // 이건 cgColor.components가 제대로 없을 가능성 있음
        XCTAssertNil(color.toHex(isAlpha: true))
    }

    // MARK: - init(hex:) Tests
    func testInitHex_valid6Digit() throws {
        let color = UIColor(hex: "FF0000")
        XCTAssertNotNil(color)
        XCTAssertEqual(Double(color?.cgColor.components?[0] ?? -1), 1.0, accuracy: 0.01)
        XCTAssertEqual(Double(color?.cgColor.components?[1] ?? -1), 0.0, accuracy: 0.01)
        XCTAssertEqual(Double(color?.cgColor.components?[2] ?? -1), 0.0, accuracy: 0.01)
    }

    func testInitHex_validWithHash() throws {
        let color = UIColor(hex: "#00FF00")
        XCTAssertNotNil(color)
        XCTAssertEqual(Double(color?.cgColor.components?[1] ?? -1), 1.0, accuracy: 0.01) // Green
    }

    func testInitHex_invalidLength() throws {
        let color = UIColor(hex: "FFF")
        XCTAssertNil(color)
    }

    func testInitHex_nilInput() throws {
        let color = UIColor(hex: nil)
        XCTAssertNil(color)
    }

    func testInitHex_withAlphaParameter() throws {
        let color = UIColor(hex: "#0000FF", alpha: 0.3)
        XCTAssertNotNil(color)
        XCTAssertEqual(Double(color?.cgColor.alpha ?? -1), 0.3, accuracy: 0.01)
    }
}
