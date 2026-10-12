//
//  ActivityShareItemPreparerTests.swift
//  CommonUtilsTests
//

import XCTest
import UIKit
@testable import CommonUtils

final class ActivityShareItemPreparerTests: XCTestCase {
    private var testTemporaryDirectory: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()

        testTemporaryDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("ActivityShareItemPreparerTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(
            at: testTemporaryDirectory,
            withIntermediateDirectories: true
        )
    }

    override func tearDownWithError() throws {
        if FileManager.default.fileExists(atPath: testTemporaryDirectory.path) {
            try FileManager.default.removeItem(at: testTemporaryDirectory)
        }
        testTemporaryDirectory = nil

        try super.tearDownWithError()
    }

    func testSupportedDataCreatesFilesWithDetectedExtensionsAndOriginalContents() throws {
        let samples = [
            (name: "sample", extension: "jpg", expectedExtension: "jpg"),
            (name: "sample", extension: "jpeg", expectedExtension: "jpg"),
            (name: "sample", extension: "png", expectedExtension: "png"),
            (name: "sample", extension: "gif", expectedExtension: "gif"),
            (name: "sample", extension: "heic", expectedExtension: "heic"),
            (name: "video_720p", extension: "mp4", expectedExtension: "mp4")
        ]

        for sample in samples {
            let originalData = try loadTestData(
                named: sample.name,
                extension: sample.extension
            )
            let preparer = makePreparer(activityItems: [originalData])
            defer { preparer.cleanup() }

            let fileURL = try XCTUnwrap(preparer.activityItems.first as? URL)
            XCTAssertTrue(fileURL.isFileURL)
            XCTAssertEqual(fileURL.pathExtension, sample.expectedExtension)
            XCTAssertEqual(fileURL.pathExtension, originalData.mimeType?.ext)
            XCTAssertEqual(try Data(contentsOf: fileURL), originalData)
        }
    }

    func testMultipleDataPreservesCountAndOrder() throws {
        let jpegData = try loadTestData(named: "sample", extension: "jpg")
        let pngData = try loadTestData(named: "sample", extension: "png")
        let gifData = try loadTestData(named: "sample", extension: "gif")
        let preparer = makePreparer(activityItems: [jpegData, pngData, gifData])
        defer { preparer.cleanup() }

        XCTAssertEqual(preparer.activityItems.count, 3)
        let fileURLs = try preparer.activityItems.map { try XCTUnwrap($0 as? URL) }
        XCTAssertEqual(fileURLs.map(\.pathExtension), ["jpg", "png", "gif"])
        XCTAssertEqual(
            try fileURLs.map { try Data(contentsOf: $0) },
            [jpegData, pngData, gifData]
        )
    }

    func testSameTypeDataCreatesDifferentFileURLs() throws {
        let jpegData = try loadTestData(named: "sample", extension: "jpg")
        let preparer = makePreparer(activityItems: [jpegData, jpegData])
        defer { preparer.cleanup() }

        let firstURL = try XCTUnwrap(preparer.activityItems[0] as? URL)
        let secondURL = try XCTUnwrap(preparer.activityItems[1] as? URL)

        XCTAssertNotEqual(firstURL, secondURL)
        XCTAssertEqual(firstURL.lastPathComponent, "share-1.jpg")
        XCTAssertEqual(secondURL.lastPathComponent, "share-2.jpg")
    }

    func testNSDataCreatesFileURL() throws {
        let jpegData = try loadTestData(named: "sample", extension: "jpg")
        let nsData = jpegData as NSData
        let preparer = makePreparer(activityItems: [nsData])
        defer { preparer.cleanup() }

        let fileURL = try XCTUnwrap(preparer.activityItems.first as? URL)
        XCTAssertEqual(try Data(contentsOf: fileURL), jpegData)
    }

    func testNonDataItemsRemainUnchanged() throws {
        let string = "공유 텍스트"
        let nsString = NSMutableString(string: "NSString 텍스트")
        let attributedString = NSAttributedString(string: "서식 텍스트")
        let webURL = try XCTUnwrap(URL(string: "https://example.com/share"))
        let existingFileURL = testTemporaryDirectory.appendingPathComponent("existing.txt")
        try Data("existing".utf8).write(to: existingFileURL)
        let image = UIImage()
        let items: [Any] = [
            string,
            nsString,
            attributedString,
            webURL,
            existingFileURL,
            image
        ]

        let preparer = makePreparer(activityItems: items)

        XCTAssertEqual(preparer.activityItems.count, items.count)
        XCTAssertEqual(preparer.activityItems[0] as? String, string)
        XCTAssertTrue(preparer.activityItems[1] as? NSString === nsString)
        XCTAssertTrue(preparer.activityItems[2] as? NSAttributedString === attributedString)
        XCTAssertEqual(preparer.activityItems[3] as? URL, webURL)
        XCTAssertEqual(preparer.activityItems[4] as? URL, existingFileURL)
        XCTAssertTrue(preparer.activityItems[5] as? UIImage === image)
        XCTAssertNil(preparer.temporaryDirectoryURL)
    }

    func testUnknownDataRemainsOriginalData() {
        let unknownData = Data([0x00, 0x01, 0x02, 0x03])
        let preparer = makePreparer(activityItems: [unknownData])

        XCTAssertEqual(preparer.activityItems.first as? Data, unknownData)
        XCTAssertNil(preparer.temporaryDirectoryURL)
    }

    func testEmptyDataRemainsOriginalData() {
        let emptyData = Data()
        let preparer = makePreparer(activityItems: [emptyData])

        XCTAssertEqual(preparer.activityItems.first as? Data, emptyData)
        XCTAssertNil(preparer.temporaryDirectoryURL)
    }

    func testZipDataIsNotMaterialized() {
        let zipData = Data(
            [0x50, 0x4B, 0x03, 0x04] + Array(repeating: 0x00, count: 46)
        )
        let preparer = makePreparer(activityItems: [zipData])

        XCTAssertEqual(preparer.activityItems.first as? Data, zipData)
        XCTAssertNil(preparer.temporaryDirectoryURL)
    }

    func testDisabledMaterializationKeepsSupportedDataUnchanged() throws {
        let jpegData = try loadTestData(named: "sample", extension: "jpg")
        let preparer = makePreparer(
            activityItems: [jpegData],
            shouldMaterializeData: false
        )

        XCTAssertEqual(preparer.activityItems.first as? Data, jpegData)
        XCTAssertNil(preparer.temporaryDirectoryURL)
    }

    func testMixedItemsPreserveCountAndOrder() throws {
        let text = "text"
        let jpegData = try loadTestData(named: "sample", extension: "jpg")
        let webURL = try XCTUnwrap(URL(string: "https://example.com"))
        let pngData = try loadTestData(named: "sample", extension: "png")
        let existingFileURL = testTemporaryDirectory.appendingPathComponent("existing.txt")
        try Data("existing".utf8).write(to: existingFileURL)
        let preparer = makePreparer(
            activityItems: [text, jpegData, webURL, pngData, existingFileURL]
        )
        defer { preparer.cleanup() }

        XCTAssertEqual(preparer.activityItems.count, 5)
        XCTAssertEqual(preparer.activityItems[0] as? String, text)
        XCTAssertEqual((preparer.activityItems[1] as? URL)?.pathExtension, "jpg")
        XCTAssertEqual(preparer.activityItems[2] as? URL, webURL)
        XCTAssertEqual((preparer.activityItems[3] as? URL)?.pathExtension, "png")
        XCTAssertEqual(preparer.activityItems[4] as? URL, existingFileURL)
    }

    func testCleanupRemovesSessionDirectoryAndIsIdempotent() throws {
        let jpegData = try loadTestData(named: "sample", extension: "jpg")
        let preparer = makePreparer(activityItems: [jpegData])
        let directoryURL = try XCTUnwrap(preparer.temporaryDirectoryURL)
        let fileURL = try XCTUnwrap(preparer.activityItems.first as? URL)

        XCTAssertTrue(FileManager.default.fileExists(atPath: directoryURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path))

        preparer.cleanup()
        preparer.cleanup()

        XCTAssertFalse(FileManager.default.fileExists(atPath: directoryURL.path))
        XCTAssertNil(preparer.temporaryDirectoryURL)
    }

    func testWriteFailureKeepsFailedItemAndPreservesSuccessfulItem() throws {
        enum TestError: Error {
            case writeFailed
        }

        let jpegData = try loadTestData(named: "sample", extension: "jpg")
        let pngData = try loadTestData(named: "sample", extension: "png")
        let preparer = makePreparer(
            activityItems: [jpegData, pngData],
            dataWriter: { data, fileURL in
                if fileURL.lastPathComponent == "share-1.jpg" {
                    throw TestError.writeFailed
                }
                try data.write(to: fileURL, options: .atomic)
            }
        )
        defer { preparer.cleanup() }

        XCTAssertEqual(preparer.activityItems[0] as? Data, jpegData)
        let pngFileURL = try XCTUnwrap(preparer.activityItems[1] as? URL)
        XCTAssertEqual(try Data(contentsOf: pngFileURL), pngData)
    }

    func testDeinitRemovesSessionDirectory() throws {
        let jpegData = try loadTestData(named: "sample", extension: "jpg")
        weak var weakPreparer: ActivityShareItemPreparer?
        var directoryURL: URL?

        autoreleasepool {
            let preparer = makePreparer(activityItems: [jpegData])
            weakPreparer = preparer
            directoryURL = preparer.temporaryDirectoryURL
        }

        XCTAssertNil(weakPreparer)
        let unwrappedDirectoryURL = try XCTUnwrap(directoryURL)
        XCTAssertFalse(FileManager.default.fileExists(atPath: unwrappedDirectoryURL.path))
    }

    func testCleanupDoesNotRemoveAnotherSessionDirectory() throws {
        let jpegData = try loadTestData(named: "sample", extension: "jpg")
        let firstPreparer = makePreparer(activityItems: [jpegData])
        let secondPreparer = makePreparer(activityItems: [jpegData])
        defer {
            firstPreparer.cleanup()
            secondPreparer.cleanup()
        }

        let firstDirectoryURL = try XCTUnwrap(firstPreparer.temporaryDirectoryURL)
        let secondDirectoryURL = try XCTUnwrap(secondPreparer.temporaryDirectoryURL)
        XCTAssertNotEqual(firstDirectoryURL, secondDirectoryURL)

        firstPreparer.cleanup()

        XCTAssertFalse(FileManager.default.fileExists(atPath: firstDirectoryURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: secondDirectoryURL.path))
    }

    func testPreparationRequirementUsesInjectedMaterializationFlag() throws {
        let jpegData = try loadTestData(named: "sample", extension: "jpg")

        XCTAssertTrue(
            ActivityShareItemPreparer.requiresPreparation(
                activityItems: [jpegData],
                shouldMaterializeData: true
            )
        )
        XCTAssertFalse(
            ActivityShareItemPreparer.requiresPreparation(
                activityItems: [jpegData],
                shouldMaterializeData: false
            )
        )
        XCTAssertFalse(
            ActivityShareItemPreparer.requiresPreparation(
                activityItems: ["text", Data()],
                shouldMaterializeData: true
            )
        )
    }

    #if targetEnvironment(simulator)
    func testSimulatorDoesNotMaterializeDataInCurrentEnvironment() {
        XCTAssertFalse(ActivityShareEnvironment.shouldMaterializeData)
    }
    #endif
}

private extension ActivityShareItemPreparerTests {
    func loadTestData(named name: String, extension fileExtension: String) throws -> Data {
        let fileURL = try XCTUnwrap(
            Bundle.module.url(forResource: name, withExtension: fileExtension)
        )
        return try Data(contentsOf: fileURL)
    }

    func makePreparer(
        activityItems: [Any],
        shouldMaterializeData: Bool = true,
        dataWriter: ActivityShareItemPreparer.DataWriter? = nil
    ) -> ActivityShareItemPreparer {
        ActivityShareItemPreparer.prepare(
            activityItems: activityItems,
            shouldMaterializeData: shouldMaterializeData,
            temporaryDirectory: testTemporaryDirectory,
            dataWriter: dataWriter
        )
    }
}
