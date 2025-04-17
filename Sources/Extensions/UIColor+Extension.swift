//
//  UIColor+Extension.swift
//
//
// Created by Dongju Lim on 2023/06/14.
//

import UIKit

public extension UIColor {
    // notaTODO: - Computed Properties
    var toHex: String? {
        return toHex()
    }

    // notaTODO: - From UIColor to String
    func toHex(isAlpha: Bool = false) -> String? {
        guard let rgbColor = self.cgColor.converted(to: CGColorSpace(name: CGColorSpace.sRGB)!, intent: .defaultIntent, options: nil),
              let components = rgbColor.components,
              components.count >= 3 else {
            return nil
        }


        let red = Float(components[0])
        let green = Float(components[1])
        let blue = Float(components[2])
        let alphaValue = Float(rgbColor.alpha)

        if isAlpha {
            return String(format: "%02lX%02lX%02lX%02lX",
                          lroundf(red * 255), lroundf(green * 255), lroundf(blue * 255), lroundf(alphaValue * 255))
        } else {
            return String(format: "%02lX%02lX%02lX",
                          lroundf(red * 255), lroundf(green * 255), lroundf(blue * 255))
        }
    }

    // https://stackoverflow.com/questions/57870527/scanhexint32-was-deprecated-in-ios-13-0
    convenience init?(hex: String?, alpha: CGFloat = 1.0) {
        guard let hex = hex else { return nil }
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        guard hexSanitized.count == 6 else { return nil }  // ← assert → guard
        var rgbValue: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgbValue)

        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)

    }
}
