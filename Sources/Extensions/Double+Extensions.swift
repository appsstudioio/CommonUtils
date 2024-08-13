//
//  Double+Extensions.swift
//
//
//  Created by 10-N3344 on 2023/06/14.
//

import Foundation

public extension Double {
    func toStringCommas(digits: Int = 2) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = Locale(identifier: "ko_KR")
        numberFormatter.roundingMode = .floor
        numberFormatter.minimumFractionDigits = digits
        numberFormatter.maximumFractionDigits = digits
        return (numberFormatter.string(from: NSNumber(value: self)) ?? "")
    }
    
    var toM2: Double {
        return (self * 3.3057)
    }
    
    var toPyeong: Double {
        return (self * 0.3025)
    }

    var toDate: Date? {
        return Date(timeIntervalSince1970: self)
    }

    var toTimeString: String {
        let seconds: Int = Int(self.truncatingRemainder(dividingBy: 60.0))
        let minutes: Int = Int(self / 60.0)
        return String(format: "%d:%02d", minutes, seconds)
    }
}
