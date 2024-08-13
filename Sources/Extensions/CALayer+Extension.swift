//
//  CALayer+Extension.swift
//
//
//  Created by 10-N3344 on 8/12/24.
//

import UIKit
import QuartzCore

public extension CALayer {

    func makeShadow(_ color: UIColor = UIColor(red: 0.412, green: 0.465, blue: 0.646, alpha: 0.3),
                    x offsetX: CGFloat = 0,
                    y offsetY: CGFloat = 10,
                    blur: CGFloat = 40,
                    spread: CGFloat = 0) {
        shadowColor = color.cgColor
        shadowOpacity = 1
        shadowOffset = CGSize(width: offsetX, height: offsetY)
        shadowRadius = blur / 2
        if spread == 0 {
            shadowPath = nil
        } else {
            let rect = bounds.insetBy(dx: -spread, dy: -spread)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }

    // https://ios-development.tistory.com/841
    func shakingAnimation(_ duration: CFTimeInterval = 0.4) {
        let animation = CAKeyframeAnimation(keyPath: "position.x")
        animation.values = [0, 7.5, -7.5, 7.5, -2.5, 2.5, -2.5, 0 ]
        animation.keyTimes = [0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1]
        animation.duration = duration
        // true이면 values가 현재 위치 기준, false이면 values가 Screen좌표 기준
        animation.isAdditive = true
        self.add(animation, forKey: "shaking")
    }

    func addBorder(_ arr_edge: [UIRectEdge], color: UIColor, width: CGFloat) {
        self.sublayers?.forEach{
            if $0.name == "addBorder" {
                $0.removeFromSuperlayer()
            }
        }

        for edge in arr_edge {
            let border = CALayer()
            border.name = "addBorder"
            switch edge {
            case UIRectEdge.top:
                border.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: width)
                break
            case UIRectEdge.bottom:
                border.frame = CGRect.init(x: 0, y: frame.height - width, width: frame.width, height: width)
                break
            case UIRectEdge.left:
                border.frame = CGRect.init(x: 0, y: 0, width: width, height: frame.height)
                break
            case UIRectEdge.right:
                border.frame = CGRect.init(x: frame.width - width, y: 0, width: width, height: frame.height)
                break
            default:
                break
            }
            border.backgroundColor = color.cgColor;
            self.addSublayer(border)
        }
    }

    func addDashBorder(frame: CGRect,
                       dashWidth: CGFloat,
                       dashColor: UIColor,
                       lineDashPattern: [NSNumber],
                       cornerRadius: CGFloat = 0 ) {
        let dashBorder = CAShapeLayer()
        dashBorder.lineWidth = dashWidth
        dashBorder.strokeColor = dashColor.cgColor
        dashBorder.lineDashPattern = lineDashPattern
        dashBorder.frame = frame
        dashBorder.fillColor = nil
        if cornerRadius > 0 {
            dashBorder.path = UIBezierPath(roundedRect: frame, cornerRadius: cornerRadius).cgPath
        } else {
            dashBorder.path = UIBezierPath(rect: frame).cgPath
        }
        self.addSublayer(dashBorder)
    }

    func fadeAnimation(duration: CFTimeInterval,
                       subtype: CATransitionSubtype,
                       timingFunction: CAMediaTimingFunctionName = .easeInEaseOut,
                       transitionType: CATransitionType = .push ) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: timingFunction)
        animation.duration = duration
        animation.type = CATransitionType.fade
        animation.subtype = subtype
        self.add(animation, forKey: transitionType.rawValue)
    }

    func moveInAnimation(duration: CFTimeInterval,
                         subtype: CATransitionSubtype,
                         timingFunction: CAMediaTimingFunctionName = .easeInEaseOut,
                         transitionType: CATransitionType = .push ) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: timingFunction)
        animation.duration = duration
        animation.type = CATransitionType.moveIn
        animation.subtype = subtype
        self.add(animation, forKey: transitionType.rawValue)
    }

    func pushAnimation(duration: CFTimeInterval,
                       subtype: CATransitionSubtype,
                       timingFunction: CAMediaTimingFunctionName = .easeInEaseOut,
                       transitionType: CATransitionType = .push ) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: timingFunction)
        animation.duration = duration
        animation.type = CATransitionType.push
        animation.subtype = subtype
        self.add(animation, forKey: transitionType.rawValue)
    }

    func revealAnimation(duration: CFTimeInterval,
                         subtype: CATransitionSubtype,
                         timingFunction: CAMediaTimingFunctionName = .easeInEaseOut,
                         transitionType: CATransitionType = .push ) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: timingFunction)
        animation.duration = duration
        animation.type = CATransitionType.reveal
        animation.subtype = subtype
        self.add(animation, forKey: transitionType.rawValue)
    }

    func bottomAnimation(duration: CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.duration = duration
        animation.type = CATransitionType.push
        animation.subtype = CATransitionSubtype.fromTop
        self.add(animation, forKey: CATransitionType.push.rawValue)
    }

    func topAnimation(duration: CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.duration = duration
        animation.type = CATransitionType.push
        animation.subtype = CATransitionSubtype.fromBottom
        self.add(animation, forKey: CATransitionType.push.rawValue)
    }
}


