//
//  ArrayExtensionTests.swift
//  CommonUtils
//
// Created by Dongju Lim on 4/14/25.
//

import XCTest
@testable import CommonUtils

final class ArrayExtensionTests: XCTestCase {

    // MARK: - Sequence
    func testUniqued_withDuplicates() throws {
        let input = [1, 2, 2, 3, 3, 3]
        let result = input.uniqued()
        XCTAssertEqual(result, [1, 2, 3])
    }

    func testUniqued_withEmptyArray() throws {
        let input: [Int] = []
        let result = input.uniqued()
        XCTAssertEqual(result, [])
    }

    func testUniqued_withStrings() throws {
        let input = ["a", "b", "a", "c"]
        let result = input.uniqued()
        XCTAssertEqual(result, ["a", "b", "c"])
    }

    // MARK: - toData
    func testToData_withValidArray() throws {
        let input = ["a", "b", "c"]
        let data = input.toData
        XCTAssertNotNil(data)
    }

    func testToData_withEmptyArray() throws {
        let input: [String] = []
        let data = input.toData
        XCTAssertNotNil(data)
    }

    func testToData_withInvalidObject() throws {
        class Custom {}
        let array: [Any] = [Custom()]
        let data = array.toData
        XCTAssertNil(data)
    }

    // MARK: - toJsonString
    func testToJsonString_withValidArray() throws {
        let input = [1, 2, 3]
        let json = input.toJsonString
        XCTAssertEqual(json, "[1,2,3]")
    }

    func testToJsonString_withStringArray() throws {
        let input = ["a", "b"]
        let json = input.toJsonString
        XCTAssertEqual(json, #"["a","b"]"#)
    }

    func testToJsonString_withEmptyArray() throws {
        let input: [Int] = []
        let json = input.toJsonString
        XCTAssertEqual(json, "[]")
    }

    // MARK: - unique
    struct User {
        let id: Int
        let name: String
    }

    func testUnique_withStructArray() throws {
        let input = [User(id: 1, name: "A"), User(id: 2, name: "B"), User(id: 1, name: "A2")]
        let result = input.unique { $0.id }
        XCTAssertEqual(result.count, 2)
    }

    func testUnique_withStringsByLength() throws {
        let input = ["a", "bb", "cc", "ddd", "ee"]
        let result = input.unique { $0.count }
        XCTAssertEqual(result, ["a", "bb", "ddd"])
    }

    func testUnique_withEmptyArray() throws {
        let input: [Int] = []
        let result = input.unique { $0 }
        XCTAssertEqual(result, [])
    }

    // MARK: - toDecodableObject
    struct Person: Codable, Equatable {
        let name: String
        let age: Int
    }

    func testToDecodableObject_success() throws {
        let jsonArray: [[String: Any]] = [["name": "John", "age": 30]]
        let data = try! JSONSerialization.data(withJSONObject: jsonArray)
        let decoded = try? JSONDecoder().decode([Person].self, from: data)
        let result = jsonArray.toDecodableObject(model: [Person].self)
        XCTAssertEqual(result as? [Person], decoded)
    }

    func testToDecodableObject_failOnInvalidKey() throws {
        let jsonArray: [[String: Any]] = [["username": "John", "age": 30]]
        let result = jsonArray.toDecodableObject(model: [Person].self)
        XCTAssertNil(result)
    }

    func testToDecodableObject_emptyArray() throws {
        let jsonArray: [[String: Any]] = []
        let result = jsonArray.toDecodableObject(model: [Person].self)
        XCTAssertEqual((result as? [Person])?.count, 0)
    }

    // MARK: - subscript(safe index: Int)
    func testSafeIndex_withValidIndex() throws {
        let array = [10, 20, 30]
        XCTAssertEqual(array[safe: 1], 20)
    }

    func testSafeIndex_withOutOfBoundsIndex() throws {
        let array = [10, 20, 30]
        XCTAssertNil(array[safe: 3])
    }

    func testSafeIndex_withNegativeIndex() throws {
        let array = [10, 20, 30]
        XCTAssertNil(array[safe: -1])
    }
}
