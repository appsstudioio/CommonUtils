//
//  DictionaryExtensionTests.swift
//  CommonUtils
//
// Created by Dongju Lim on 4/15/25.
//

import XCTest
@testable import CommonUtils

final class DictionaryExtensionTests: XCTestCase {
    // MARK: - toData
    func testToData() throws {
        let dict: [String: Any] = ["name": "Alice", "age": 30]
        let data = dict.toData
        XCTAssertNotNil(data)
        XCTAssertTrue(data != nil)
    }

    // MARK: - toString
    func testToStringDefaultDivider() throws {
        let dict: [String: Any] = ["a": 1, "b": "hello"]
        let result = dict.toString()
        XCTAssertTrue(result.contains("a=1"))
        XCTAssertTrue(result.contains("b=hello"))
        XCTAssertTrue(result.contains(","))
    }

    func testToStringCustomDivider() throws {
        let dict: [String: Any] = ["x": true, "y": 3.14]
        let result = dict.toString(divide: " | ")
        XCTAssertTrue(result.contains("x=true"))
        XCTAssertTrue(result.contains("y=3.14"))
        XCTAssertTrue(result.contains(" | "))
    }

    // MARK: - filterReturnString
    func testFilterReturnString() throws {
        let dict: [String: Any] = ["id": 123, "name": "Bob", "score": 4.5]

        XCTAssertEqual(dict.filterReturnString(key: "id"), "123")
        XCTAssertEqual(dict.filterReturnString(key: "name"), "Bob")
        XCTAssertEqual(dict.filterReturnString(key: "score"), "4.5")
        XCTAssertNil(dict.filterReturnString(key: "missing"))
    }

    // MARK: - toJsonString
    func testToJsonString() throws {
        let dict: [String: Any] = ["foo": "bar"]
        let jsonString = dict.toJsonString
        XCTAssertTrue(jsonString.contains("\"foo\":\"bar\""))
    }

    // MARK: - toDecodableObject
    struct User: Codable, Equatable {
        let name: String
        let age: Int
    }

    func testToDecodableObjectSuccess() throws {
        let dict: [String: Any] = ["name": "Charlie", "age": 28]
        let user = dict.toDecodableObject(model: User.self) as? User
        XCTAssertEqual(user, User(name: "Charlie", age: 28))
    }

    func testToDecodableObjectFailure() throws {
        let dict: [String: Any] = ["name": "Charlie", "age": "notAnInt"]
        let user = dict.toDecodableObject(model: User.self) as? User
        XCTAssertNil(user)
    }
}
