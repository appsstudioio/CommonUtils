//
//  Int+Extensions.swift
//
//
//  Created by 10-N3344 on 2023/06/14.
//

import Foundation

public extension Int {
    func withCommas(_ locale: Locale = .current) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.locale = locale
        if self < 1 {
            return "0"
        }
        return (numberFormatter.string(from: NSNumber(value: self)) ?? "")
    }
    
    func withCurrencySpellOut(_ locale: Locale = .current) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.spellOut
        numberFormatter.locale = locale
        return (numberFormatter.string(from: NSNumber(value: self)) ?? "")
    }

    var toFloat: Float {
        return Float(self)
    }

    var toDouble: Double {
        return Double(self)
    }

    var unixtimeToDate: Date {
        return Date(timeIntervalSince1970: TimeInterval((self / 1000)))
    }

    var toFileByteSting: String {
        return NSNumber(value: self).toFileSizeString
    }

    var degreesToRadians: CGFloat {
        return CGFloat(self) * .pi / 180.0
    }
}

// MARK: - Int64
public extension Int64 {
    func withCommas(_ locale: Locale = .current) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.locale = locale
        return (numberFormatter.string(from: NSNumber(value: self)) ?? "")
    }
    
    func withCurrencySpellOut(_ locale: Locale = .current) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.spellOut
        numberFormatter.locale = locale
        return (numberFormatter.string(from: NSNumber(value: self)) ?? "")
    }

    var toFloat: Float {
        return Float(self)
    }

    var toDouble: Double {
        return Double(self)
    }

    var toFileByteSting: String {
        return NSNumber(value: self).toFileSizeString
    }
}

public extension NSNumber {
    var toFileSizeString: String {
        var convertedValue: Double = Double(self.uint64Value)
        var multiplyFactor = 0
        // bytes
        let tokens = ["B", "KB", "MB", "GB", "TB", "PB",  "EB",  "ZB", "YB"]
        while convertedValue > 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        return String(format: "%4.2f%@", convertedValue, tokens[multiplyFactor])
    }
}
