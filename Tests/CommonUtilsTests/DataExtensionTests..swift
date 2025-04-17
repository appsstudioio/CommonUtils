//
//  DataExtensionTests..swift
//  CommonUtils
//
// Created by Dongju Lim on 4/14/25.
//

import XCTest
@testable import CommonUtils

final class DataExtensionTests: XCTestCase {
    // MARK: - toJsonDic 테스트
    func test_toJsonDic_validJsonData_returnsDictionary() throws {
        let json = ["name": "ChatGPT", "age": 3] as [String: Any]
        let data = try! JSONSerialization.data(withJSONObject: json)
        let result = data.toJsonDic
        XCTAssertEqual(result?["name"] as? String, "ChatGPT")
    }

    func test_toJsonDic_invalidJsonData_returnsNil() throws {
        let data = "invalid".data(using: .utf8)!
        XCTAssertNil(data.toJsonDic)
    }

    func test_toJsonDic_emptyData_returnsNil() throws {
        let data = Data()
        XCTAssertNil(data.toJsonDic)
    }

    func test_toJsonDic_nestedJson_returnsCorrectValue() throws {
        let json = ["meta": ["id": 123, "type": "user"]]
        let data = try! JSONSerialization.data(withJSONObject: json)
        let result = data.toJsonDic
        let meta = result?["meta"] as? [String: Any]
        XCTAssertEqual(meta?["id"] as? Int, 123)
    }

    func test_toJsonDic_arrayJson_returnsNil() throws {
        let json = [["name": "A"], ["name": "B"]]
        let data = try! JSONSerialization.data(withJSONObject: json)
        XCTAssertNil(data.toJsonDic) // not a dictionary
    }

    // MARK: - toJsonStrng 테스트
    func test_toJsonStrng_validUtf8Data_returnsString() throws {
        let string = "Hello, World!"
        let data = string.data(using: .utf8)!
        XCTAssertEqual(data.toJsonStrng, string)
    }

    func test_toJsonStrng_invalidUtf8Data_returnsNil() throws {
        let data = Data([0xD8, 0x00]) // invalid utf-8
        XCTAssertNil(data.toJsonStrng)
    }

    func test_toJsonStrng_emptyData_returnsEmptyString() throws {
        let data = Data()
        XCTAssertEqual(data.toJsonStrng, "")
    }

    func test_toJsonStrng_containsSpecialCharacters() throws {
        let string = "한글😊"
        let data = string.data(using: .utf8)!
        XCTAssertEqual(data.toJsonStrng, string)
    }

    func test_toJsonStrng_largeData() throws {
        let string = String(repeating: "A", count: 10_000)
        let data = string.data(using: .utf8)!
        XCTAssertEqual(data.toJsonStrng, string)
    }

    // MARK: - mimeType & getImageMimeType 테스트
    func test_getImageMimeType_jpeg_returnsCorrectUTI() throws {
        guard let path = Bundle.module.url(forResource: "sample", withExtension: "jpg") else {
            throw XCTSkip("이미지 리소스 없음")
        }
        let data = try! Data(contentsOf: path)
        let mime = data.getImageMimeType()
        XCTAssertTrue(mime?.contains("jpeg") ?? false)
    }

    func test_getImageMimeType_nonImage_returnsNil() throws {
        let data = "Just text".data(using: .utf8)!
        XCTAssertNil(data.getImageMimeType())
    }

    func test_mimeType_jpg_returnsMimeType() throws {
        guard let path = Bundle.module.url(forResource: "sample", withExtension: "jpg") else {
            throw XCTSkip("이미지 리소스 없음")
        }
        let data = try! Data(contentsOf: path)
        XCTAssertEqual(data.mimeType?.type, .jpg)
    }

    func test_mimeType_png_returnsMimeType() throws {
        guard let path = Bundle.module.url(forResource: "sample", withExtension: "png") else {
            throw XCTSkip("이미지 리소스 없음")
        }
        let data = try! Data(contentsOf: path)
        XCTAssertEqual(data.mimeType?.type, .png)
    }

    func test_mimeType_jpeg_returnsMimeType() throws {
        guard let path = Bundle.module.url(forResource: "sample", withExtension: "jpeg") else {
            throw XCTSkip("이미지 리소스 없음")
        }
        let data = try! Data(contentsOf: path)
        XCTAssertEqual(data.mimeType?.type, .jpg)
    }

    func test_mimeType_gif_returnsMimeType() throws {
        guard let path = Bundle.module.url(forResource: "sample", withExtension: "gif") else {
            throw XCTSkip("이미지 리소스 없음")
        }
        let data = try! Data(contentsOf: path)
        XCTAssertEqual(data.mimeType?.type, .gif)
    }

    func test_mimeType_heic_returnsHeicType() throws {
        // HEIC 파일 필요. 테스트용으로 넣어야 함.
        guard let path = Bundle.module.url(forResource: "sample", withExtension: "heic") else {
            throw XCTSkip("이미지 리소스 없음")
        }
        let data = try! Data(contentsOf: path)
        XCTAssertEqual(data.mimeType?.type, .heic)
    }

    func test_mimeType_text_returnsNil() throws {
        let data = "hello".data(using: .utf8)!
        XCTAssertNil(data.mimeType?.type.rawValue.contains("image"))
    }

    // MARK: - toBytes, kilobytes, megabytes, gigabytes 테스트
    func test_toBytes_correctConversion() throws {
        let data = Data(repeating: 0, count: 1024)
        XCTAssertEqual(data.toBytes, 1024)
    }

    func test_kilobytes_conversionAccuracy() throws {
        let data = Data(repeating: 0, count: 2048)
        XCTAssertEqual(data.toKilobytes, 2.0, accuracy: 0.001)
    }

    func test_megabytes_conversionAccuracy() throws {
        let data = Data(repeating: 0, count: 1024 * 1024)
        XCTAssertEqual(data.toMegabytes, 1.0, accuracy: 0.001)
    }

    func test_gigabytes_conversionAccuracy() throws {
        let data = Data(repeating: 0, count: 1024 * 1024 * 1024)
        XCTAssertEqual(data.toGigabytes, 1.0, accuracy: 0.001)
    }

    func test_zeroData_conversionsAreZero() throws {
        let data = Data()
        XCTAssertEqual(data.toKilobytes, 0)
        XCTAssertEqual(data.toMegabytes, 0)
        XCTAssertEqual(data.toGigabytes, 0)
    }

    // MARK: - getReadableUnit() 테스트
    func test_getReadableUnit_bytes() throws {
        let data = Data(repeating: 0, count: 512)
        XCTAssertEqual(data.getReadableUnit(), "512B")
    }

    func test_getReadableUnit_kilobytes() throws {
        let data = Data(repeating: 0, count: 1500)
        XCTAssertTrue(data.getReadableUnit().contains("KB"))
    }

    func test_getReadableUnit_megabytes() throws {
        let data = Data(repeating: 0, count: 2 * 1024 * 1024)
        XCTAssertTrue(data.getReadableUnit().contains("MB"))
    }

    func test_getReadableUnit_gigabytes() throws {
        let data = Data(repeating: 0, count: 2 * 1024 * 1024 * 1024)
        XCTAssertTrue(data.getReadableUnit().contains("GB"))
    }

    func test_getReadableUnit_emptyData() throws {
        let data = Data()
        XCTAssertEqual(data.getReadableUnit(), "0B")
    }
}
