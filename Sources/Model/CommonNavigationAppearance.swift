import UIKit

public enum CommonNavigationBarStyle {
    case legacy
    case system
    case customBackground
}

@MainActor
public enum CommonNavigationAppearance {
    // 앱에서 명시적으로 켠 경우에만 공통 버튼을 시스템 스타일로 생성한다.
    public static var isEnabled = false
    public static var buttonTintColor: UIColor = .label

    public static var usesSystemButtons: Bool {
        if #available(iOS 26.0, *) {
            return isEnabled
        }
        return false
    }

    public static func makeAppearance(backgroundColor: UIColor,
                                      foregroundColor: UIColor,
                                      font: UIFont,
                                      largeFont: UIFont? = nil,
                                      style: CommonNavigationBarStyle) -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        switch style {
        case .system, .legacy:
            // 시스템 버튼을 사용해도 화면에서 지정한 배경과 제목 색상은 유지한다.
            appearance.configureWithOpaqueBackground()
        case .customBackground:
            appearance.configureWithTransparentBackground()
        }
        appearance.backgroundColor = backgroundColor
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        appearance.titleTextAttributes = [.foregroundColor: foregroundColor, .font: font]
        if let largeFont {
            appearance.largeTitleTextAttributes = [.foregroundColor: foregroundColor, .font: largeFont]
        }
        if #available(iOS 26.0, *), style == .system {
            // Glass의 자동 글자색 선택 대신 텍스트 버튼의 기존 색상을 명시한다.
            for button in [appearance.buttonAppearance, appearance.doneButtonAppearance, appearance.backButtonAppearance] {
                button.normal.titleTextAttributes[.foregroundColor] = foregroundColor
                button.highlighted.titleTextAttributes[.foregroundColor] = foregroundColor
                button.disabled.titleTextAttributes[.foregroundColor] = foregroundColor.withAlphaComponent(0.3)
            }
        }
        return appearance
    }
}
