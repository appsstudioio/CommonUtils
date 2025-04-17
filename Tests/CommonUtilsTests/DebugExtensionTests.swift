//
//  DebugExtensionTests.swift
//  CommonUtils
//
// Created by Dongju Lim on 4/15/25.
//

import XCTest
@testable import CommonUtils

final class DebugExtensionTests: XCTestCase {

    // MARK: - Data.prettyString
    func test_prettyString_utf8ValidData() throws {
        let data = "Hello, World!".data(using: .utf8)!
        XCTAssertEqual(data.prettyString, "Hello, World!")
    }

    func test_prettyString_invalidEncoding() throws {
        let data = Data([0xD8, 0x00]) // Invalid UTF-8
        XCTAssertNil(data.prettyString)
    }

    func test_prettyString_emptyData() throws {
        let data = Data()
        XCTAssertEqual(data.prettyString, "")
    }

    func test_prettyString_jsonData() throws {
        let json = ["name": "ChatGPT"]
        let data = try JSONSerialization.data(withJSONObject: json)
        XCTAssertTrue(data.prettyString?.contains("ChatGPT") ?? false)
    }

    func test_prettyString_specialCharacters() throws {
        let data = "😀🔥🚀".data(using: .utf8)!
        XCTAssertEqual(data.prettyString, "😀🔥🚀")
    }

    // MARK: - Data.toPrettyString
    func test_toPrettyString_validJSON() throws {
        let json = ["key": "value", "number": 42] as [String: Any]
        let data = try JSONSerialization.data(withJSONObject: json)
        let pretty = data.toPrettyString
        XCTAssertTrue(pretty.contains("\"key\""))
        XCTAssertTrue(pretty.contains("\"value\""))
        XCTAssertTrue(pretty.contains("\"number\""))
    }

    func test_toPrettyString_invalidJSON() throws {
        let invalidJSON = Data([0xFF, 0xD8])
        XCTAssertEqual(invalidJSON.toPrettyString, "")
    }

    func test_toPrettyString_emptyData() throws {
        let data = Data()
        XCTAssertEqual(data.toPrettyString, "")
    }

    func test_toPrettyString_nestedJSON() throws {
        let json = ["outer": ["inner": "value"]]
        let data = try JSONSerialization.data(withJSONObject: json)
        let pretty = data.toPrettyString
        XCTAssertTrue(pretty.contains("outer"))
        XCTAssertTrue(pretty.contains("inner"))
        XCTAssertTrue(pretty.contains("value"))
    }

    func test_toPrettyString_arrayJSON() throws {
        let array = [["id": 1], ["id": 2]]
        let data = try JSONSerialization.data(withJSONObject: array)
        let pretty = data.toPrettyString
        XCTAssertTrue(pretty.contains("["))
        XCTAssertTrue(pretty.contains("id"))
    }

    // MARK: - Dictionary.debugPrettyString
    func test_debugPrettyString_validDictionary() throws {
        let dict = ["name": "ChatGPT", "lang": "Swift"]
        let result = dict.debugPrettyString
        XCTAssertTrue(result.contains("ChatGPT"))
        XCTAssertTrue(result.contains("Swift"))
    }

    func test_debugPrettyString_emptyDictionary() throws {
        let dict: [String: Any] = [:]
        XCTAssertEqual(dict.debugPrettyString, "{\n\n}")
    }

    func test_debugPrettyString_nestedDictionary() throws {
        let dict: [String: Any] = ["outer": ["inner": "value"]]
        let result = dict.debugPrettyString
        XCTAssertTrue(result.contains("outer"))
        XCTAssertTrue(result.contains("inner"))
        XCTAssertTrue(result.contains("value"))
    }

    func test_debugPrettyString_invalidJSONType() throws {
        struct NotJSONEncodable {}
        let dict: [String: Any] = ["custom": NotJSONEncodable()]
        XCTAssertEqual(dict.debugPrettyString, "")
    }

    func test_debugPrettyString_arrayValue() throws {
        let dict: [String: Any] = ["list": [1, 2, 3]]
        let result = dict.debugPrettyString
        XCTAssertTrue(result.contains("list"))
        XCTAssertTrue(result.contains("1"))
    }

    // MARK: - Encodable.debugPrettyString
    struct Sample: Encodable {
        let name: String
        let age: Int
    }

    struct NestedSample: Encodable {
        let user: Sample
    }

    func test_debugPrettyString_simpleStruct() throws {
        let sample = Sample(name: "Alice", age: 30)
        let result = sample.debugPrettyString
        XCTAssertTrue(result.contains("Alice"))
        XCTAssertTrue(result.contains("age"))
    }

    func test_debugPrettyString_nestedStruct() throws {
        let nested = NestedSample(user: Sample(name: "Bob", age: 40))
        let result = nested.debugPrettyString
        XCTAssertTrue(result.contains("Bob"))
        XCTAssertTrue(result.contains("user"))
    }

    func test_debugPrettyString_emptyValues() throws {
        struct Empty: Encodable {}
        let value = Empty()
        XCTAssertEqual(value.debugPrettyString, "{\n\n}")
    }

    func test_debugPrettyString_specialCharacters() throws {
        let sample = Sample(name: "🔥🚀", age: 1)
        let result = sample.debugPrettyString
        XCTAssertTrue(result.contains("🔥🚀"))
    }

    func test_debugPrettyString_sortingKeys() throws {
        struct MixedOrder: Encodable {
            let z: String
            let a: String
        }
        let sample = MixedOrder(z: "last", a: "first")
        let result = sample.debugPrettyString

        guard let zRange = result.range(of: "\"z\""),
              let aRange = result.range(of: "\"a\"") else {
            XCTFail("Could not find keys in debugPrettyString")
            return
        }

        let zIndex = result.distance(from: result.startIndex, to: zRange.lowerBound)
        let aIndex = result.distance(from: result.startIndex, to: aRange.lowerBound)

        XCTAssertTrue(aIndex < zIndex)
    }
}
