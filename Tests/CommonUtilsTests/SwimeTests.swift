//
// SwimeTests.swift
// CommonUtils
//
// Created by Dongju Lim on 4/29/25
//

import XCTest
@testable import CommonUtils

final class SwimeTests: XCTestCase {

    // MARK: - Helper
    private func loadTestFile(named fileName: String, fileExtension: String) throws -> Data {
        guard let url = Bundle.module.url(forResource: fileName, withExtension: fileExtension) else {
            throw NSError(domain: "SwimeTests", code: 404, userInfo: [NSLocalizedDescriptionKey: "File not found: \(fileName).\(fileExtension)"])
        }
        return try Data(contentsOf: url)
    }

    // MARK: - Tests
    func testDetectJPEG() throws {
        let data = try loadTestFile(named: "sample", fileExtension: "jpg")
        let mime = Swime.mimeType(data: data)

        XCTAssertEqual(mime?.mime, "image/jpeg")
        XCTAssertEqual(mime?.ext, "jpg")
    }

    func testDetectPNG() throws {
        let data = try loadTestFile(named: "sample", fileExtension: "png")
        let mime = Swime.mimeType(data: data)

        XCTAssertEqual(mime?.mime, "image/png")
        XCTAssertEqual(mime?.ext, "png")
    }

    func testDetectGIF() throws {
        let data = try loadTestFile(named: "sample", fileExtension: "gif")
        let mime = Swime.mimeType(data: data)

        XCTAssertEqual(mime?.mime, "image/gif")
        XCTAssertEqual(mime?.ext, "gif")
    }

    func testDetectHEIC() throws {
        let data = try loadTestFile(named: "sample", fileExtension: "heic")
        let mime = Swime.mimeType(data: data)

        XCTAssertEqual(mime?.mime, "image/heic")
        XCTAssertEqual(mime?.ext, "heic")
    }

    func testUnknownFile() throws {
        let data = Data([0x00, 0x01, 0x02, 0x03])
        let mime = Swime.mimeType(data: data)
        XCTAssertNil(mime)
    }

    func testEmptyData() throws {
        let data = Data()
        let mime = Swime.mimeType(data: data)
        XCTAssertNil(mime)
    }
}
