//
//  UIScrollView+Extension.swift
//  CommonUtils
//
// Created by Dongju Lim on 3/18/25.
//

import UIKit

public extension UIScrollView {

    func scrollToBottom(animated: Bool) {
        let contentHeight = contentSize.height - frame.size.height
        let contentoffsetY = contentHeight > 0 ? contentHeight : 0
        setContentOffset(CGPoint(x: 0, y: contentoffsetY), animated: animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let afterContsHeight = self.contentSize.height - self.frame.size.height

            if contentHeight != afterContsHeight {
                self.scrollToBottom(animated: animated)
            }
        }
    }
}
