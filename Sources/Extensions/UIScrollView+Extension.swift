//
//  UIScrollView+Extension.swift
//  CommonUtils
//
// Created by Dongju Lim on 3/18/25.
//

import UIKit

public extension UIScrollView {

    // 재귀 횟수를 제한하는 매개변수 추가
    func scrollToBottom(animated: Bool, recursionCount: Int = 0) {
        let contentHeight = contentSize.height - frame.size.height
        let contentoffsetY = contentHeight > 0 ? contentHeight : 0
        setContentOffset(CGPoint(x: 0, y: contentoffsetY), animated: animated)

        // 재귀 횟수 제한 (예: 최대 3회)
        if recursionCount < 3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let afterContsHeight = self.contentSize.height - self.frame.size.height

                if contentHeight != afterContsHeight {
                    self.scrollToBottom(animated: animated, recursionCount: recursionCount + 1)
                }
            }
        }
    }
    
}
