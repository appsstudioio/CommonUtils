//
//  UILabel+Extension.swift
//
//
// Created by Dongju Lim on 10/10/23.
//
import Foundation
import UIKit

public extension UILabel {
    private var attributes: [NSAttributedString.Key: Any] {
        return self.attributedText?.attributes(at: 0, effectiveRange: nil) ?? [:]
    }
}
