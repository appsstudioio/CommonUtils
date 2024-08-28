//
//  UINavigationBar+Extension.swift
//
//
//  Created by 10-N3344 on 8/28/24.
//

import UIKit

public extension UINavigationBar {
    
    func setNavigationBarStyle(_ backgroundColor: UIColor, fontColor foregroundColor: UIColor, font: UIFont, largeFont: UIFont) {
        self.titleTextAttributes = [.foregroundColor: UIColor.white, .font: font]
        self.tintColor = foregroundColor
        self.isTranslucent = false
        self.backgroundColor = backgroundColor
        self.barTintColor = backgroundColor

        let scrollEdgeAppearance = UINavigationBarAppearance()
        scrollEdgeAppearance.configureWithOpaqueBackground()
        scrollEdgeAppearance.shadowColor = .clear
        scrollEdgeAppearance.shadowImage = UIImage()
        scrollEdgeAppearance.backgroundColor = backgroundColor
        scrollEdgeAppearance.largeTitleTextAttributes = [.foregroundColor : foregroundColor, .font : largeFont]
        scrollEdgeAppearance.titleTextAttributes = [.foregroundColor : foregroundColor, .font : font]
        self.standardAppearance = scrollEdgeAppearance
        self.scrollEdgeAppearance = scrollEdgeAppearance
    }

}
