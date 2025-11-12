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
        prefersLargeTitles: Bool = false
    ) {
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = backgroundColor
            appearance.shadowColor = .clear
            appearance.shadowImage = UIImage() // 명시적으로 빈 이미지 설정

            // 기본 타이틀
            appearance.titleTextAttributes = [
                .foregroundColor: foregroundColor,
                .font: font
            ]

            // Large title이 켜져 있을 때만 적용
            if prefersLargeTitles, let largeFont = largeFont {
                appearance.largeTitleTextAttributes = [
                    .foregroundColor: foregroundColor,
                    .font: largeFont
                ]
            }

            // Appearance 일괄 적용
            self.standardAppearance = appearance
            self.scrollEdgeAppearance = appearance
//            self.compactAppearance = appearance
//            self.compactScrollEdgeAppearance = appearance
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
        self.tintColor = foregroundColor
        self.prefersLargeTitles = prefersLargeTitles
    }
}
