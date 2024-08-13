//
//  UIView+Extension.swift
//
//
//  Created by 10-N3344 on 8/13/24.
//

import UIKit
#if canImport(SwiftUI)
import SwiftUI
#endif
import Combine

public extension UIView {
    #if canImport(SwiftUI)
    private struct Preview: UIViewRepresentable {
        let view: UIView

        func makeUIView(context: Context) -> UIView {
            return view
        }

        func updateUIView(_ uiView: UIView, context: Context) {}
    }

    func preview() -> some View {
        Preview(view: self)
    }
    #endif

    enum VerticalLocation {
        case bottom
        case top
        case left
        case right
    }

    func addshadow(top: Bool,
                   left: Bool,
                   bottom: Bool,
                   right: Bool,
                   offset: CGSize = CGSize(width: 0.0, height: 0.0),
                   fx frameX: CGFloat = 0,
                   fy frameY: CGFloat = 0,
                   color: UIColor = .black,
                   shadowRadius: CGFloat = 5.0) {

        self.layer.masksToBounds = false
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = 1.0
        self.layer.shadowColor = color.cgColor

        let path = UIBezierPath()
        var posX: CGFloat = frameX
        var posY: CGFloat = frameY
        var viewWidth = self.frame.width
        var viewHeight = self.frame.height

        // here x, y, viewWidth, and viewHeight can be changed in
        // order to play around with the shadow paths.
        if top {
            posY += (shadowRadius+1)
        }
        if bottom {
            viewHeight -= (shadowRadius+1)
        }
        if left {
            posX += (shadowRadius+1)
        }
        if right {
            viewWidth -= (shadowRadius+1)
        }
        // selecting top most point
        path.move(to: CGPoint(x: posX, y: posY))
        // Move to the Bottom Left Corner, this will cover left edges
        path.addLine(to: CGPoint(x: posX, y: viewHeight))
        // Move to the Bottom Right Corner, this will cover bottom edge
        path.addLine(to: CGPoint(x: viewWidth, y: viewHeight))
        // Move to the Top Right Corner, this will cover right edge
        path.addLine(to: CGPoint(x: viewWidth, y: posY))
        // Move back to the initial point, this will cover the top edge
        path.close()
        self.layer.shadowPath = path.cgPath
    }

    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.frame = self.bounds
        mask.path = path.cgPath
        self.layer.mask = mask
    }

    /**
     화면 터치할 때 키보드 내리기
     */
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIView.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.addGestureRecognizer(tap)
    }

    /**
     화면 터치할 때 키보드 내리기
     */
    func hideKeyboardWhenTappedAround(_ targetView: UIView) {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIView.dismissKeyboard))
        tap.cancelsTouchesInView = false
        targetView.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        self.endEditing(true)
    }

    func keyboardHeight() -> AnyPublisher<CGFloat,Never> {
        Publishers.Merge (
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
                .map{($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0},
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in CGFloat(0) }
        ).eraseToAnyPublisher()
    }

    func screenshot(viewArea: Bool = false) -> UIImage {
        if let scrollView = self as? UIScrollView {
            if viewArea == false {
                // 스크롤뷰 전체영역
                let savedContentOffset = scrollView.contentOffset
                let savedFrame = scrollView.frame

                UIGraphicsBeginImageContextWithOptions(scrollView.bounds.size, false, UIScreen.main.scale)
                scrollView.contentOffset = .zero
                self.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
                let context = UIGraphicsGetCurrentContext()!
                context.interpolationQuality = .high
                self.layer.render(in: context)
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()

                scrollView.contentOffset = savedContentOffset
                scrollView.frame = savedFrame
                return image!
            } else {
                // 보이는 부분만
                UIGraphicsBeginImageContextWithOptions(scrollView.bounds.size, false, UIScreen.main.scale)
                let offset = scrollView.contentOffset
                let thisContext = UIGraphicsGetCurrentContext()!
                thisContext.interpolationQuality = .high
                thisContext.translateBy(x: -offset.x, y: -offset.y)
                scrollView.layer.render(in: thisContext)
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return image!
            }
        }

        // UIGraphicsBeginImageContext(self.bounds.size)
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale )
        let context = UIGraphicsGetCurrentContext()!
        context.interpolationQuality = .high
        self.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!

    }

    var deviceWidthSize: CGFloat {
        return UIScreen.main.bounds.size.width
    }

    // https://stackoverflow.com/questions/32151637/swift-get-all-subviews-of-a-specific-type-and-add-to-an-array
    /** This is the function to get subViews of a view of a particular type
    */
    func subViews<T : UIView>(type : T.Type) -> [T]{
        var all = [T]()
        for view in self.subviews {
            if let aView = view as? T{
                all.append(aView)
            }
        }
        return all
    }

    /** This is a function to get subViews of a particular type from view recursively. It would look recursively in all subviews and return back the subviews of the type T */
    func allSubViewsOf<T : UIView>(type : T.Type) -> [T]{
        var all = [T]()
        func getSubview(view: UIView) {
            if let aView = view as? T{
            all.append(aView)
            }
            guard view.subviews.count>0 else { return }
            view.subviews.forEach{ getSubview(view: $0) }
        }
        getSubview(view: self)
        return all
    }

    func viewByClassName(className: String) -> UIView? {
        let name = NSStringFromClass(type(of: self))
        if name == className {
            return self
        } else {
            for subview in self.subviews {
                if let view = subview.viewByClassName(className: className) {
                    return view
                }
            }
        }
        return nil
    }
}


