//
//  CGSize+Extension.swift
//
//
//  Created by 10-N3344 on 8/12/24.
//

import Foundation
import UIKit
import AVFoundation

public extension CGSize {
    func getViewHeight(newWidth: CGFloat) -> CGSize {
        let scale = newWidth / self.width
        let newHeight = self.height * scale
        return CGSize(width: newWidth, height: newHeight)
    }

    // Calculates the best height of the image for available width.
    func height(forWidth width: CGFloat) -> CGFloat {
        let boundingRect = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: CGFloat(MAXFLOAT)
        )
        let rect = AVMakeRect(
            aspectRatio: self,
            insideRect: boundingRect
        )
        return rect.size.height
    }
}

public extension CGFloat {
    func getViewImageHeight(imageSize: CGSize) -> CGFloat {
        return ((self / imageSize.width) * imageSize.height)
    }
}