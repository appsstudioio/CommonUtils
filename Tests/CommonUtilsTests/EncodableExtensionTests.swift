//
//  EncodableExtensionTests.swift
//  CommonUtils
//
// Created by Dongju Lim on 4/15/25.
//

import XCTest
@testable import CommonUtils

// 테스트용 모델 정의
private struct TestModel: Codable, Equatable {
    let id: Int
    let name: String
    let isActive: Bool
}

final class EncodableExtensionTests: XCTestCase {
    // MARK: - asDictionary
    func test_asDictionary_validModel_shouldReturnDictionary() throws {
        let model = TestModel(id: 1, name: "Alice", isActive: true)
        let dict = try model.asDictionary()
        XCTAssertEqual(dict["id"] as? Int, 1)
        XCTAssertEqual(dict["name"] as? String, "Alice")
        XCTAssertEqual(dict["isActive"] as? Bool, true)
    }

    func test_asDictionary_withEmptyString_shouldReturnValidDictionary() throws {
        let model = TestModel(id: 0, name: "", isActive: false)
        let dict = try model.asDictionary()
        XCTAssertEqual(dict["name"] as? String, "")
        XCTAssertEqual(dict["id"] as? Int, 0)
        XCTAssertEqual(dict["isActive"] as? Bool, false)
    }

    func test_asDictionary_differentData_shouldMatchExpectedKeys() throws {
        let model = TestModel(id: 123, name: "Test", isActive: true)
        let dict = try model.asDictionary()
        XCTAssertTrue(dict.keys.contains("id"))
        XCTAssertTrue(dict.keys.contains("name"))
        XCTAssertTrue(dict.keys.contains("isActive"))
    }

    func test_asDictionary_shouldThrowErrorManually() throws {
        struct InvalidModel: Encodable {
            func encode(to encoder: Encoder) throws {
                throw NSError(domain: "Test", code: 999, userInfo: [NSLocalizedDescriptionKey: "Manual encode failure"])
            }
        }

        let model = InvalidModel()
        XCTAssertThrowsError(try model.asDictionary())
    }

    func test_asDictionary_shouldReturnCorrectType() throws {
        let model = TestModel(id: 10, name: "Bob", isActive: false)
        let dict = try model.asDictionary()
        XCTAssertTrue(type(of: dict) == [String: Any].self)
    }

    // MARK: - toDictionary
    func test_toDictionary_validModel_shouldReturnNonNil() throws {
        let model = TestModel(id: 1, name: "Alice", isActive: true)
        let dict = model.toDictionary
        XCTAssertNotNil(dict)
    }

    func test_toDictionary_shouldContainCorrectKeys() throws {
        let model = TestModel(id: 99, name: "XYZ", isActive: false)
        let dict = model.toDictionary
        XCTAssertTrue(dict?.keys.contains("id") ?? false)
        XCTAssertTrue(dict?.keys.contains("name") ?? false)
        XCTAssertTrue(dict?.keys.contains("isActive") ?? false)
    }

    func test_toDictionary_shouldReturnNilOnEncodingFailure() throws {
        struct FailingModel: Encodable {
            let value = Date() // JSONEncoder encodes it, but we simulate failure
            func encode(to encoder: Encoder) throws {
                throw NSError(domain: "Test", code: 1, userInfo: nil)
            }
        }
        let model = FailingModel()
        XCTAssertNil(model.toDictionary)
    }

    func test_toDictionary_shouldCorrectlyMapValues() throws {
        let model = TestModel(id: 42, name: "Answer", isActive: true)
        let dict = model.toDictionary
        XCTAssertEqual(dict?["id"] as? Int, 42)
        XCTAssertEqual(dict?["name"] as? String, "Answer")
    }

    func test_toDictionary_shouldReturnDictionaryType() throws {
        let model = TestModel(id: 5, name: "Test", isActive: false)
        let result = model.toDictionary
        XCTAssertNotNil(result)
        XCTAssertTrue(result != nil)
    }

    // MARK: - asString
    func test_asString_validModel_shouldReturnJSONString() throws {
        let model = TestModel(id: 1, name: "Alice", isActive: true)
        let json = try model.asString()
        XCTAssertTrue(json?.contains("\"name\":\"Alice\"") ?? false)
    }

    func test_asString_shouldReturnNonNil() throws {
        let model = TestModel(id: 0, name: "", isActive: false)
        let json = try model.asString()
        XCTAssertNotNil(json)
    }

    func test_asString_shouldEncodeCorrectFormat() throws {
        let model = TestModel(id: 10, name: "JSON", isActive: true)
        let json = try model.asString()
        XCTAssertTrue(json?.hasPrefix("{") ?? false)
        XCTAssertTrue(json?.hasSuffix("}") ?? false)
    }

    func test_asString_shouldContainAllFields() throws {
        let model = TestModel(id: 77, name: "Fields", isActive: true)
        let json = try model.asString()
        XCTAssertTrue(json?.contains("77") ?? false)
        XCTAssertTrue(json?.contains("Fields") ?? false)
        XCTAssertTrue(json?.contains("true") ?? false)
    }

    func test_asString_shouldThrowOnFailure() throws {
        struct ThrowingModel: Encodable {
            func encode(to encoder: Encoder) throws {
                throw NSError(domain: "Test", code: 123, userInfo: nil)
            }
        }
        let model = ThrowingModel()
        XCTAssertThrowsError(try model.asString())
    }
}
