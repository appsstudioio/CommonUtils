//
//  PaddingLaebl.swift
// 
//
//  Created by 10-N3344 on 1/29/24.
//

import UIKit

@IBDesignable public class PaddingLabel: UILabel {
    @IBInspectable var topInset: CGFloat    = 4.0
    @IBInspectable var bottomInset: CGFloat = 4.0
    @IBInspectable var leftInset: CGFloat   = 6.0
    @IBInspectable var rightInset: CGFloat  = 6.0

    public override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    public override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset, height: size.height + topInset + bottomInset)
    }

    public func setPadding(edgeInset: UIEdgeInsets) {
        self.topInset = edgeInset.top
        self.bottomInset = edgeInset.bottom
        self.leftInset = edgeInset.left
        self.rightInset = edgeInset.right
    }
}
