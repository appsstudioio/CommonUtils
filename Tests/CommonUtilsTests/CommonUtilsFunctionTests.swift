//
// CommonUtilsFunctionTests.swift
// CommonUtils
//
// Created by Dongju Lim on 5/9/25
//

import XCTest
import AVFoundation
@testable import CommonUtils

final class CommonUtilsFunctionTests: XCTestCase {

    // MARK: - Helper to load video URL from bundle or temp
    private func loadTestVideo(named name: String, withExtension ext: String = "mp4") -> URL? {
        return Bundle.module.url(forResource: name, withExtension: ext)
    }

    // MARK: - Test: MP4 - Standard 1080p video
    func testExtractInfo_1080pMP4() throws {
        guard let url = loadTestVideo(named: "video_1080p") else {
            XCTFail("Missing test video")
            return
        }

        let info = CommonUtils.extractVideoInfo(from: url)

        XCTAssertGreaterThan(info.duration, 1.0)
        XCTAssertEqual(info.resolution, CGSize(width: 1080, height: 1920))
        XCTAssertNotNil(info.frameRate)
        XCTAssertNotNil(info.bitRate)
        XCTAssertEqual(info.videoCodec, "avc1") // H.264
        XCTAssertNotNil(info.audioCodec)
    }

    // MARK: - Test: Short clip (less than 5 seconds)
    func testExtractInfo_ShortClip() throws {
        guard let url = loadTestVideo(named: "video_720p") else {
            XCTFail("Missing test video")
            return
        }

        let info = CommonUtils.extractVideoInfo(from: url)
        XCTAssertLessThan(info.duration, 5.2)
        XCTAssertNotNil(info.frameRate)
        XCTAssertNotNil(info.resolution)
    }

    // MARK: - Test: No audio track
    func testExtractInfo_VideoWithoutAudio() throws {
        guard let url = loadTestVideo(named: "video_no_audio") else {
            XCTFail("Missing test video")
            return
        }

        let info = CommonUtils.extractVideoInfo(from: url)
        XCTAssertNil(info.audioCodec)
        XCTAssertNil(info.audioSampleRate)
        XCTAssertNil(info.audioChannels)
    }

    // MARK: - Test: 4K Video
    func testExtractInfo_4KVideo() throws {
        guard let url = loadTestVideo(named: "video_2160p") else {
            XCTFail("Missing test video")
            return
        }

        let info = CommonUtils.extractVideoInfo(from: url)
        XCTAssertEqual(info.resolution, CGSize(width: 2160, height: 3840))
        XCTAssertGreaterThan(info.bitRate ?? 0, 5_000_000)
    }

    // MARK: - Test: Invalid file
    func testExtractInfo_InvalidFileReturnsZeroDuration() throws {
        let dummyURL = URL(fileURLWithPath: "/tmp/invalid_video.mp4")
        let info = CommonUtils.extractVideoInfo(from: dummyURL)

        XCTAssertEqual(info.duration, 0)
        XCTAssertNil(info.resolution)
        XCTAssertNil(info.videoCodec)
    }
}

final class VideoCompressionTests: XCTestCase {

    // 테스트용 비디오 파일 경로
    var inputVideoURL: URL!
    var outputVideoURL: URL!

    // MARK: - Helper to load video URL from bundle or temp
    private func loadTestVideo(named name: String, withExtension ext: String = "mp4") -> URL? {
        return Bundle.module.url(forResource: name, withExtension: ext)
    }

    override func setUpWithError() throws {
        try super.setUpWithError()

        guard let videoPath = loadTestVideo(named: "video_2160p") else {
            XCTFail("테스트용 video_2160p.mp4 파일을 찾을 수 없음")
            return
        }

        inputVideoURL = videoPath
        outputVideoURL = FileManager.default.temporaryDirectory.appendingPathComponent("compressed.mp4")

        // 기존 파일 삭제
        if FileManager.default.fileExists(atPath: outputVideoURL.path) {
            try FileManager.default.removeItem(at: outputVideoURL)
        }
    }

    override func tearDownWithError() throws {
        if FileManager.default.fileExists(atPath: outputVideoURL.path) {
            try FileManager.default.removeItem(at: outputVideoURL)
        }
        try super.tearDownWithError()
    }

    // MARK: - 기본 압축 성공 케이스
    func testCompressVideo_Success() throws {
        let expectation = XCTestExpectation(description: "비디오 압축 성공")

        CommonUtils.compressVideo(inputURL: inputVideoURL,
                                  outputURL: outputVideoURL,
                                  quality: .medium) { result in
            switch result {
            case .success(let url):
                XCTAssertTrue(FileManager.default.fileExists(atPath: url.path), "압축된 파일이 존재해야 함")
                let compressedSize = try? Data(contentsOf: url).count
                XCTAssertNotNil(compressedSize, "압축된 파일의 크기를 가져와야 함")
            case .failure(let error):
                XCTFail("압축 실패: \(error)")
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 30)
    }

    // MARK: - 너무 작은 maxFileSize로 인해 압축 실패
    func testCompressVideo_TooSmallMaxFileSize_ShouldFail() throws {
        let expectation = XCTestExpectation(description: "너무 작은 파일 크기로 압축 실패")

        CommonUtils.compressVideo(inputURL: inputVideoURL,
                                  outputURL: outputVideoURL,
                                  quality: .low,
                                  maxFileSize: 1024) { result in // 1KB 제한
            switch result {
            case .success:
                XCTFail("너무 작은 maxFileSize인데 압축이 성공하면 안됨")
            case .failure(let error):
                XCTAssertTrue("\(error)".contains("minimumQualityExceedsMaxFileSize"), "최소 품질로도 크기 초과 에러여야 함")
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 30)
    }

    // MARK: - 오디오 없는 비디오도 정상 압축 처리
    func testCompressVideo_NoAudioTrack_Success() throws {
        // 오디오 트랙이 없는 샘플 파일을 미리 프로젝트에 포함시켜야 함 (예: "no_audio.mp4")
        guard let videoPath = loadTestVideo(named: "video_no_audio") else {
            XCTFail("video_no_audio.mp4 파일이 필요합니다")
            return
        }

        let inputURL = videoPath
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("compressed_no_audio.mp4")

        let expectation = XCTestExpectation(description: "오디오 없는 비디오도 압축 성공")

        CommonUtils.compressVideo(inputURL: inputURL,
                                 outputURL: outputURL,
                                 quality: .medium) { result in
            switch result {
            case .success(let url):
                XCTAssertTrue(FileManager.default.fileExists(atPath: url.path), "압축된 파일이 존재해야 함")
            case .failure(let error):
                XCTFail("압축 실패: \(error)")
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 30)
    }

}
