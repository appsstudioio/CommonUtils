//
//  UILabel+Extension.swift
//
//
//  Created by 10-N3344 on 10/10/23.
//
import Foundation
import UIKit

public extension UILabel {
    private var attributes: [NSAttributedString.Key: Any] {
        return self.attributedText?.attributes(at: 0, effectiveRange: nil) ?? [:]
    }
}
