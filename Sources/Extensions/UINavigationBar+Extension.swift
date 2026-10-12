//
//  UINavigationBar+Extension.swift
//
//
// Created by Dongju Lim on 8/28/24.
//

import UIKit

public extension UINavigationBar {

    func setNavigationBarStyle(
        _ backgroundColor: UIColor,
        fontColor foregroundColor: UIColor,
        font: UIFont,
        largeFont: UIFont? = nil,
        prefersLargeTitles: Bool = false,
        style: CommonNavigationBarStyle = .legacy
    ) {
        if #available(iOS 15.0, *) {
            let appearance = CommonNavigationAppearance.makeAppearance(
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                font: font,
                largeFont: prefersLargeTitles ? largeFont : nil,
                style: style
            )
            self.standardAppearance = appearance
            self.scrollEdgeAppearance = appearance
            if style != .legacy {
                self.compactAppearance = appearance
                self.compactScrollEdgeAppearance = appearance
            }
        } else {
            // iOS 14 이하 fallback
            self.titleTextAttributes = [
                .foregroundColor: foregroundColor,
                .font: font
            ]

            if prefersLargeTitles, let largeFont = largeFont {
                self.largeTitleTextAttributes = [
                    .foregroundColor: foregroundColor,
                    .font: largeFont
                ]
            }
            self.barTintColor = backgroundColor
            self.backgroundColor = backgroundColor
            self.isTranslucent = false
            self.shadowImage = UIImage()
            self.setBackgroundImage(UIImage(), for: .default)
        }
        // 공통 설정
        if #available(iOS 26.0, *), style == .system {
            self.setBackgroundImage(nil, for: .default)
            self.shadowImage = nil
            self.backgroundColor = nil
            self.barTintColor = nil
            self.isTranslucent = true
        }
        // 텍스트 버튼은 기존 색상을 상속하고 이미지 버튼은 개별 tintColor를 사용한다.
        self.tintColor = foregroundColor
        self.prefersLargeTitles = prefersLargeTitles
    }
}
