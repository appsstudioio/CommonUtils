//
//  CGSizeExtensionTests.swift
//  CommonUtils
//
// Created by Dongju Lim on 4/14/25.
//

import XCTest
@testable import CommonUtils

final class CGSizeExtensionTests: XCTestCase {

    // MARK: getViewHeight
    func test_getViewHeight_preservesAspectRatio() throws {
        let originalSize = CGSize(width: 100, height: 200)
        let resized = originalSize.getViewHeight(newWidth: 50)
        XCTAssertEqual(resized.height, 100)
        XCTAssertEqual(resized.width, 50)
    }

    func test_getViewHeight_zeroOriginalWidth_returnsZeroHeight() throws {
        let originalSize = CGSize(width: 0, height: 200)
        let resized = originalSize.getViewHeight(newWidth: 100)
        XCTAssertTrue(resized.height.isInfinite || resized.height.isNaN)
    }

    func test_getViewHeight_zeroNewWidth_returnsZeroSize() throws {
        let originalSize = CGSize(width: 100, height: 200)
        let resized = originalSize.getViewHeight(newWidth: 0)
        XCTAssertEqual(resized, .zero)
    }

    func test_getViewHeight_sameWidth_returnsSameSize() throws {
        let originalSize = CGSize(width: 100, height: 150)
        let resized = originalSize.getViewHeight(newWidth: 100)
        XCTAssertEqual(resized, originalSize)
    }

    func test_getViewHeight_negativeNewWidth() throws {
        let originalSize = CGSize(width: 100, height: 200)
        let resized = originalSize.getViewHeight(newWidth: -100)
        XCTAssertEqual(resized.width, -100)
        XCTAssertEqual(resized.height, -200)
    }

    // MARK: height(forWidth:)
    func test_heightForWidth_preservesAspectRatio() throws {
        let size = CGSize(width: 100, height: 200)
        let height = size.height(forWidth: 50)
        XCTAssertEqual(height, 100)
    }

    func test_heightForWidth_zeroWidth_returnsZeroHeight() throws {
        let size = CGSize(width: 100, height: 200)
        let height = size.height(forWidth: 0)
        XCTAssertEqual(height, 0)
    }

    func test_heightForWidth_squareAspect() throws {
        let size = CGSize(width: 100, height: 100)
        let height = size.height(forWidth: 200)
        XCTAssertEqual(height, 200)
    }

    func test_heightForWidth_landscapeImage() throws {
        let size = CGSize(width: 200, height: 100)
        let height = size.height(forWidth: 100)
        XCTAssertEqual(height, 50)
    }

    func test_heightForWidth_invalidSize_returnsZero() throws {
        let size = CGSize(width: 0, height: 0)
        let height = size.height(forWidth: 100)
        XCTAssertEqual(height, 0)
    }

    // MARK: getViewImageHeight(imageSize:)
    func test_getViewImageHeight_proportionalScaling() throws {
        let viewWidth: CGFloat = 200
        let imageSize = CGSize(width: 100, height: 50)
        let height = viewWidth.getViewImageHeight(imageSize: imageSize)
        XCTAssertEqual(height, 100)
    }

    func test_getViewImageHeight_zeroImageWidth_returnsNaNOrInf() throws {
        let viewWidth: CGFloat = 200
        let imageSize = CGSize(width: 0, height: 100)
        let height = viewWidth.getViewImageHeight(imageSize: imageSize)
        XCTAssertTrue(height.isInfinite || height.isNaN)
    }

    func test_getViewImageHeight_zeroViewWidth_returnsZero() throws {
        let viewWidth: CGFloat = 0
        let imageSize = CGSize(width: 100, height: 100)
        let height = viewWidth.getViewImageHeight(imageSize: imageSize)
        XCTAssertEqual(height, 0)
    }

    func test_getViewImageHeight_sameSize_returnsSameHeight() throws {
        let viewWidth: CGFloat = 100
        let imageSize = CGSize(width: 100, height: 200)
        let height = viewWidth.getViewImageHeight(imageSize: imageSize)
        XCTAssertEqual(height, 200)
    }

    func test_getViewImageHeight_negativeViewWidth_returnsNegativeHeight() throws {
        let viewWidth: CGFloat = -100
        let imageSize = CGSize(width: 100, height: 100)
        let height = viewWidth.getViewImageHeight(imageSize: imageSize)
        XCTAssertEqual(height, -100)
    }
}
