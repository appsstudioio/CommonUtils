//
//  IntExtensionTests.swift
//  CommonUtils
//
// Created by Dongju Lim on 4/15/25.
//

import XCTest
@testable import CommonUtils

final class IntExtensionTests: XCTestCase {

    // MARK: - withCommas
    func test_withCommas() throws {
        XCTAssertEqual(123.withCommas(), "123")
        XCTAssertEqual(1_000.withCommas(), "1,000")
        XCTAssertEqual(1_000_000.withCommas(), "1,000,000")
        XCTAssertEqual(0.withCommas(), "0")
        XCTAssertEqual(999.withCommas(Locale(identifier: "de_DE")), "999")
    }

    // MARK: - withCurrencySpellOut
    func test_withCurrencySpellOut() throws {
        XCTAssertEqual(1.withCurrencySpellOut(Locale(identifier: "en_US")), "one")
        XCTAssertEqual(2.withCurrencySpellOut(Locale(identifier: "en_US")), "two")
        XCTAssertEqual(11.withCurrencySpellOut(Locale(identifier: "ko_KR")), "십일")
        XCTAssertEqual(0.withCurrencySpellOut(Locale(identifier: "en_US")), "zero")
        XCTAssertEqual(21.withCurrencySpellOut(Locale(identifier: "en_US")), "twenty-one")
    }

    // MARK: - Conversion Properties
    func test_Conversions() throws {
        XCTAssertEqual(10.toFloat, 10.0)
        XCTAssertEqual(42.toDouble, 42.0)
        XCTAssertEqual(7.toCGFloat, CGFloat(7))
        XCTAssertEqual(1_620_000_000.unixtimeToDate.timeIntervalSince1970, 1_620_000)
        XCTAssertEqual(1024.toFileByteSting, "1.00KB")
    }

    // MARK: - degreesToRadians
    func test_degreesToRadians() throws {
        XCTAssertEqual(0.degreesToRadians, 0)
        XCTAssertEqual(180.degreesToRadians, .pi)
        XCTAssertEqual(90.degreesToRadians, .pi / 2, accuracy: 0.0001)
        XCTAssertEqual(45.degreesToRadians, .pi / 4, accuracy: 0.0001)
        XCTAssertEqual(360.degreesToRadians, .pi * 2, accuracy: 0.0001)
    }
}

// MARK: - Int64 Extension Tests
final class Int64ExtensionTests: XCTestCase {

    // MARK: - withCommas
    func test_withCommas() throws {
        XCTAssertEqual(Int64(1000).withCommas(), "1,000")
        XCTAssertEqual(Int64(1_000_000).withCommas(), "1,000,000")
        XCTAssertEqual(Int64(0).withCommas(), "0")
        XCTAssertEqual(Int64(999).withCommas(Locale(identifier: "fr_FR")), "999")
        XCTAssertEqual(Int64(123456789).withCommas(), "123,456,789")
    }

    // MARK: - withCurrencySpellOut
    func test_withCurrencySpellOut() throws {
        XCTAssertEqual(Int64(1).withCurrencySpellOut(Locale(identifier: "en_US")), "one")
        XCTAssertEqual(Int64(12).withCurrencySpellOut(Locale(identifier: "en_US")), "twelve")
        XCTAssertEqual(Int64(0).withCurrencySpellOut(Locale(identifier: "en_US")), "zero")
        XCTAssertEqual(Int64(101).withCurrencySpellOut(Locale(identifier: "en_US")), "one hundred one")
        XCTAssertEqual(Int64(21).withCurrencySpellOut(Locale(identifier: "en_US")), "twenty-one")
    }

    // MARK: - Conversion Properties
    func test_Conversions() throws {
        XCTAssertEqual(Int64(123).toFloat, 123.0)
        XCTAssertEqual(Int64(987).toDouble, 987.0)
        XCTAssertEqual(Int64(1024).toFileByteSting, "1.00KB")
        XCTAssertEqual(Int64(1048576).toFileByteSting, "1.00MB")
        XCTAssertEqual(Int64(0).toFileByteSting, "0.00B")
    }
}

// MARK: - NSNumber Extension Tests
final class NSNumberExtensionTests: XCTestCase {
    // MARK: - toFileSizeString
    func test_toFileSizeString_shouldReturnBytes() throws {
        let value = NSNumber(value: 500)
        let result = value.toFileSizeString
        XCTAssertEqual(result, "500.00B")
    }

    func test_toFileSizeString_shouldReturnKilobytes() throws {
        let value = NSNumber(value: 1024)
        let result = value.toFileSizeString
        XCTAssertEqual(result, "1.00KB")
    }

    func test_toFileSizeString_shouldReturnMegabytes() throws {
        let value = NSNumber(value: 1048576) // 1024 * 1024
        let result = value.toFileSizeString
        XCTAssertEqual(result, "1.00MB")
    }

    func test_toFileSizeString_shouldReturnGigabytes() throws {
        let value = NSNumber(value: 1073741824) // 1024^3
        let result = value.toFileSizeString
        XCTAssertEqual(result, "1.00GB")
    }

    func test_toFileSizeString_shouldReturnTerabytes() throws {
        let value = NSNumber(value: 1099511627776) // 1024^4
        let result = value.toFileSizeString
        XCTAssertEqual(result, "1.00TB")
    }
}
