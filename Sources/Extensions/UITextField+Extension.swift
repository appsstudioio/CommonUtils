//
//  UITextField+Extension.swift
//
//
// Created by Dongju Lim on 2023/09/01.
//

import Foundation
import UIKit

// https://stackoverflow.com/questions/63120812/how-to-limit-number-of-characters-in-swift-uitextfield-if-i-am-using-my-own-des
fileprivate var kAssociationKeyMaxLength: Int = 0
public extension UITextField {
    @IBInspectable var maxLength: Int {
        get {
            if let length = objc_getAssociatedObject(self, &kAssociationKeyMaxLength) as? Int {
                return length
            } else {
                return Int.max
            }
        }
        set {
            objc_setAssociatedObject(self, &kAssociationKeyMaxLength, newValue, .OBJC_ASSOCIATION_RETAIN)
            self.addTarget(self, action: #selector(checkMaxLength), for: .editingChanged)
        }
    }

    func isInputMethod() -> Bool {
        if let positionRange = self.markedTextRange {
            if let _ = self.position(from: positionRange.start, offset: 0) {
                return true
            }
        }
        return false
    }

    @objc func checkMaxLength(textField: UITextField) {
        guard !self.isInputMethod(), let prospectiveText = self.text, prospectiveText.count > maxLength else {
            return
        }

        let selection = selectedTextRange
        let maxCharIndex = prospectiveText.index(prospectiveText.startIndex, offsetBy: maxLength)
        text = String(prospectiveText[..<maxCharIndex])
        selectedTextRange = selection
    }
    
    func addPaddingAndIcon(_ image: UIImage, padding: CGFloat, isLeftView: Bool) {
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: image.size.width + padding, height: image.size.height))
        let iconView  = UIImageView(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        iconView.image = image
        outerView.addSubview(iconView)
        if isLeftView {
            leftViewMode = .always
            leftView = outerView
        } else {
            rightViewMode = .always
            rightView = outerView
        }
    }

    func removeIcon(isLeftView: Bool) {
        if isLeftView {
            leftViewMode = .never
            leftView = nil
        } else {
            rightViewMode = .never
            rightView = nil
        }
    }
}
