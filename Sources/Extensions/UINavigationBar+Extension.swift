//
//  UINavigationBar+Extension.swift
//
//
//  Created by 10-N3344 on 8/28/24.
//

import UIKit

public extension UINavigationBar {
    
    func setNavigationBarStyle(_ backgroundColor: UIColor, fontColor foregroundColor: UIColor, font: UIFont, largeFont: UIFont) {
        // iOS 15 이상: appearance API 사용
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = backgroundColor
            appearance.shadowColor = .clear
            appearance.titleTextAttributes = [
                .foregroundColor: foregroundColor,
                .font: font
            ]

            appearance.largeTitleTextAttributes = [
                .foregroundColor: foregroundColor,
                .font: largeFont
            ]

            // Appearance 적용
            self.standardAppearance = appearance
            self.scrollEdgeAppearance = appearance
            self.compactAppearance = appearance
            self.compactScrollEdgeAppearance = appearance

        } else {
            // iOS 14: 기본 속성만 설정
            self.titleTextAttributes = [
                .foregroundColor: foregroundColor,
                .font: font
            ]
            self.largeTitleTextAttributes = [
                .foregroundColor: foregroundColor,
                .font: largeFont
            ]
            self.barTintColor = backgroundColor
            self.backgroundColor = backgroundColor
        }

        // 공통 설정 (iOS 14 이상 모든 버전)
        self.tintColor = foregroundColor
        self.isTranslucent = false
        self.prefersLargeTitles = false
        self.setBackgroundImage(nil, for: .default)
        self.shadowImage = nil
    }

}
