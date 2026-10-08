import XCTest
import UIKit
@testable import CommonUtils

@MainActor
final class NavigationAppearanceTests: XCTestCase {
    func testLegacyAppearancePreservesExplicitColors() {
        let appearance = makeAppearance(style: .legacy, background: .red, foreground: .white)
        XCTAssertEqual(appearance.backgroundColor, .red)
        XCTAssertNil(appearance.backgroundEffect)
        XCTAssertEqual(appearance.titleTextAttributes[.foregroundColor] as? UIColor, .white)
    }

    func testSystemTextButtonAppearancesPreserveNormalAndDisabledColors() throws {
        guard #available(iOS 26.0, *) else { throw XCTSkip("iOS 26 이상에서 Glass 텍스트 버튼 색상을 검증합니다.") }
        let appearance = makeAppearance(style: .system, background: .blue, foreground: .white)
        for button in [appearance.buttonAppearance, appearance.doneButtonAppearance, appearance.backButtonAppearance] {
            XCTAssertEqual(button.normal.titleTextAttributes[.foregroundColor] as? UIColor, .white)
            XCTAssertEqual(button.highlighted.titleTextAttributes[.foregroundColor] as? UIColor, .white)
            XCTAssertEqual(button.disabled.titleTextAttributes[.foregroundColor] as? UIColor, UIColor.white.withAlphaComponent(0.3))
        }
    }

    func testCustomBackgroundPreservesTransparentAndPartialAlpha() {
        for alpha in [CGFloat(0), 0.5, 1] {
            let color = UIColor.red.withAlphaComponent(alpha)
            let appearance = makeAppearance(style: .customBackground, background: color, foreground: .white)
            XCTAssertEqual(appearance.backgroundColor, color)
            XCTAssertNil(appearance.backgroundEffect)
        }
    }

    func testSystemAppearancePreservesBackgroundAndTitleColors() {
        let appearance = makeAppearance(style: .system, background: .red, foreground: .white)
        XCTAssertEqual(appearance.backgroundColor, .red)
        XCTAssertNil(appearance.backgroundEffect)
        XCTAssertEqual(appearance.titleTextAttributes[.foregroundColor] as? UIColor, .white)
    }

    func testSystemStyleClearsPreviouslyAppliedLegacyBarState() {
        let bar = UINavigationBar()
        bar.backgroundColor = .red
        bar.barTintColor = .red
        bar.isTranslucent = false
        bar.setNavigationBarStyle(.red, fontColor: .white, font: .systemFont(ofSize: 18), style: .system)
        if #available(iOS 26.0, *) {
            XCTAssertNil(bar.backgroundColor)
            XCTAssertNil(bar.barTintColor)
            XCTAssertTrue(bar.isTranslucent)
        }
    }

    func testButtonFactoryOptInPreservesTargetActionAndMenu() {
        let previous = CommonNavigationAppearance.isEnabled
        defer { CommonNavigationAppearance.isEnabled = previous }
        let target = ButtonTarget()
        let image = UIImage(systemName: "magnifyingglass")
        CommonNavigationAppearance.isEnabled = false
        let legacy = UIBarButtonItem.createUIBarButtonItem(image: image, target: target, action: #selector(ButtonTarget.tap))
        XCTAssertNotNil(legacy.customView)

        CommonNavigationAppearance.isEnabled = true
        let item = UIBarButtonItem.createUIBarButtonItem(image: image, target: target, action: #selector(ButtonTarget.tap))
        let menu = UIMenu(children: [UIAction(title: "Search") { _ in }])
        let menuItem = UIBarButtonItem.createUIBarButtonItem(image: image, menu: menu)
        if #available(iOS 26.0, *) {
            XCTAssertNil(item.customView)
            XCTAssertTrue(item.target as? ButtonTarget === target)
            XCTAssertEqual(item.action, #selector(ButtonTarget.tap))
            XCTAssertEqual(item.image?.renderingMode, .alwaysTemplate)
            XCTAssertEqual(menuItem.menu?.title, menu.title)
            XCTAssertEqual(menuItem.menu?.children.map(\.title), menu.children.map(\.title))
            if let action = item.action {
                _ = (item.target as? NSObject)?.perform(action)
            }
            XCTAssertEqual(target.tapCount, 1)
        } else {
            XCTAssertNotNil(item.customView)
            XCTAssertNotNil(menuItem.customView)
        }
    }

    func testBackAndCloseKeepTheirActions() {
        let previous = CommonNavigationAppearance.isEnabled
        defer { CommonNavigationAppearance.isEnabled = previous }
        CommonNavigationAppearance.isEnabled = true
        let root = UIViewController()
        let detail = UIViewController()
        let navigation = UINavigationController(rootViewController: root)
        navigation.pushViewController(detail, animated: false)
        let target = ButtonTarget()
        detail.hideNavigationLeftButton(hidden: false, target: target, action: #selector(ButtonTarget.tap))
        navigation.popViewController(animated: false)
        root.hideNavigationLeftButton(hidden: false, target: target, action: #selector(ButtonTarget.tap))
        XCTAssertEqual(detail.navigationItem.leftBarButtonItem?.action, #selector(ButtonTarget.tap))
        XCTAssertEqual(root.navigationItem.leftBarButtonItem?.action, #selector(ButtonTarget.tap))
        XCTAssertTrue(detail.navigationItem.hidesBackButton)
        if #available(iOS 26.0, *) {
            XCTAssertEqual(detail.navigationItem.leftBarButtonItem?.accessibilityLabel, "navigation_back".localization(true))
            XCTAssertEqual(root.navigationItem.leftBarButtonItem?.accessibilityLabel, "navigation_close".localization(true))
        }
        detail.hideNavigationLeftButton(hidden: true)
        XCTAssertNil(detail.navigationItem.leftBarButtonItem)
    }

    func testConfiguredIconTintDoesNotChangeTextButtonTint() throws {
        guard #available(iOS 26.0, *) else { throw XCTSkip("iOS 26 이상에서 시스템 버튼 색상을 검증합니다.") }
        let previousEnabled = CommonNavigationAppearance.isEnabled
        let previousTint = CommonNavigationAppearance.buttonTintColor
        defer {
            CommonNavigationAppearance.isEnabled = previousEnabled
            CommonNavigationAppearance.buttonTintColor = previousTint
        }
        CommonNavigationAppearance.isEnabled = true
        CommonNavigationAppearance.buttonTintColor = .black
        let bar = UINavigationBar()
        bar.setNavigationBarStyle(.red, fontColor: .white, font: .systemFont(ofSize: 18), style: .system)
        XCTAssertEqual(bar.tintColor, .white)
        let target = ButtonTarget()
        let image = UIImage(systemName: "magnifyingglass")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        let item = UIBarButtonItem.createUIBarButtonItem(image: image, target: target, action: #selector(ButtonTarget.tap))
        XCTAssertEqual(item.image?.renderingMode, .alwaysTemplate)
        XCTAssertEqual(item.tintColor?.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark)), .black)
        let custom = UIButton(type: .custom)
        custom.setImage(image, for: .normal)
        _ = UIBarButtonItem.buttonToBarButtonItem(custom)
        XCTAssertEqual(custom.image(for: .normal)?.renderingMode, .alwaysTemplate)
        XCTAssertEqual(custom.tintColor, .black)
    }

    func testNavigationIconCenteringMovesArtworkWithoutResizing() throws {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 3
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 24, height: 24), format: format)
        let image = renderer.image { _ in
            UIColor.white.setFill()
            UIRectFill(CGRect(x: 18, y: 2, width: 4, height: 8))
        }.withRenderingMode(.alwaysOriginal)
        let centered = image.centeredNavigationIcon()
        XCTAssertEqual(centered.size, image.size)
        XCTAssertEqual(centered.scale, image.scale)
        XCTAssertEqual(centered.renderingMode, image.renderingMode)
        let alpha = try alphaPixels(centered)
        XCTAssertEqual(alpha.filter { $0 > 0 }.count, 4 * 8 * 9)
        XCTAssertEqual(alpha, Array(alpha.reversed()))
    }

    func testNavigationIconCenteringKeepsTransparentAndSystemImages() throws {
        let empty = UIGraphicsImageRenderer(size: CGSize(width: 24, height: 24)).image { _ in }
        XCTAssertTrue(empty.centeredNavigationIcon() === empty)
        let symbol = try XCTUnwrap(UIImage(systemName: "chevron.backward"))
        XCTAssertTrue(symbol.centeredNavigationIcon() === symbol)
    }

    func testNavigationIconCenteringOnlyAppliesToOptedInSystemButtons() throws {
        let previous = CommonNavigationAppearance.isEnabled
        defer { CommonNavigationAppearance.isEnabled = previous }
        let image = UIGraphicsImageRenderer(size: CGSize(width: 24, height: 24)).image { _ in
            UIColor.white.setFill()
            UIRectFill(CGRect(x: 18, y: 2, width: 4, height: 8))
        }
        let target = ButtonTarget()
        CommonNavigationAppearance.isEnabled = false
        let legacy = UIBarButtonItem.createUIBarButtonItem(image: image, target: target, action: #selector(ButtonTarget.tap))
        XCTAssertTrue((legacy.customView as? UIButton)?.image(for: .normal) === image)
        CommonNavigationAppearance.isEnabled = true
        let menu = UIMenu(children: [])
        let item = UIBarButtonItem.createUIBarButtonItem(image: image, menu: menu)
        if #available(iOS 26.0, *) {
            let alpha = try alphaPixels(XCTUnwrap(item.image))
            XCTAssertEqual(alpha, Array(alpha.reversed()))
        } else {
            XCTAssertTrue((item.customView as? UIButton)?.image(for: .normal) === image)
        }
    }

    private func alphaPixels(_ image: UIImage) throws -> [UInt8] {
        let cgImage = try XCTUnwrap(image.cgImage)
        var pixels = [UInt8](repeating: 0, count: cgImage.width * cgImage.height * 4)
        try pixels.withUnsafeMutableBytes { buffer in
            let context = try XCTUnwrap(CGContext(data: buffer.baseAddress, width: cgImage.width, height: cgImage.height,
                                                  bitsPerComponent: 8, bytesPerRow: cgImage.width * 4,
                                                  space: CGColorSpaceCreateDeviceRGB(),
                                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
        }
        return stride(from: 3, to: pixels.count, by: 4).map { pixels[$0] }
    }

    private func makeAppearance(style: CommonNavigationBarStyle, background: UIColor, foreground: UIColor) -> UINavigationBarAppearance {
        CommonNavigationAppearance.makeAppearance(backgroundColor: background, foregroundColor: foreground,
                                                 font: .systemFont(ofSize: 18), style: style)
    }
}

@MainActor
private final class ButtonTarget: NSObject {
    var tapCount = 0
    @objc func tap() { tapCount += 1 }
}
