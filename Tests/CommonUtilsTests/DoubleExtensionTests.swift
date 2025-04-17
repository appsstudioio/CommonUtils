//
//  DoubleExtensionTests.swift
//  CommonUtils
//
// Created by Dongju Lim on 4/15/25.
//

import XCTest
import CoreGraphics
@testable import CommonUtils

final class DoubleExtensionTests: XCTestCase {

    // MARK: - Double toStringCommas
    func testToStringCommas_defaultDigits() throws {
        let value: Double = 1234567.891
        let result = value.toStringCommas()
        XCTAssertEqual(result, "1,234,567.89")
    }

    func testToStringCommas_customDigits() throws {
        let value: Double = 1234.56789
        let result = value.toStringCommas(digits: 3)
        XCTAssertEqual(result, "1,234.567")
    }

    func testToStringCommas_roundingFloor() throws {
        let value: Double = 1.999
        let result = value.toStringCommas(digits: 2)
        XCTAssertEqual(result, "1.99") // not 2.00, because of .floor
    }

    // MARK: - Double Unit Conversion
    func testToM2Conversion() throws {
        let pyeong: Double = 10
        let m2 = pyeong.toM2
        XCTAssertEqual(m2, 33.057, accuracy: 0.0001)
    }

    func testToPyeongConversion() throws {
        let m2: Double = 10
        let pyeong = m2.toPyeong
        XCTAssertEqual(pyeong, 3.025, accuracy: 0.0001)
    }

    // MARK: - Double toDate
    func testToDate() throws {
        let timestamp: Double = 1_000_000
        guard let date = timestamp.toDate else {
            throw XCTSkip("데이트 변환 실패!!!")
        }
        XCTAssertEqual(date.timeIntervalSince1970, timestamp, accuracy: 0.001)
    }

    // MARK: - Double toTimeString
    func testToTimeString_exactMinute() throws {
        let value: Double = 180.0 // 3 minutes
        XCTAssertEqual(value.toTimeString, "3:00")
    }

    func testToTimeString_withSeconds() throws {
        let value: Double = 185.0 // 3 minutes 5 seconds
        XCTAssertEqual(value.toTimeString, "3:05")
    }

    func testToTimeString_zero() throws {
        let value: Double = 0.0
        XCTAssertEqual(value.toTimeString, "0:00")
    }

    // MARK: - CGFloat to Other Types
    func testCGFloatConversions() throws {
        let cg: CGFloat = 12.34
        XCTAssertEqual(cg.toDouble, 12.34, accuracy: 0.0001)
        XCTAssertEqual(cg.toFloat, Float(12.34), accuracy: 0.0001)
        XCTAssertEqual(cg.toInt, 12)
        XCTAssertEqual(cg.toInt64, 12)
    }

    // MARK: - Float to Other Types
    func testFloatConversions() throws {
        let f: Float = 56.78
        XCTAssertEqual(f.toCGFLoat, CGFloat(56.78), accuracy: 0.0001)
        XCTAssertEqual(f.toDouble, 56.78, accuracy: 0.0001)
        XCTAssertEqual(f.toInt, 56)
        XCTAssertEqual(f.toInt64, 56)
    }
}
