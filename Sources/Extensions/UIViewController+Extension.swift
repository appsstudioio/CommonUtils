//
//  UIViewController+Extension.swift
//
//
//  Created by 10-N3344 on 8/13/24.
//

import Foundation
import UIKit
import Combine
#if canImport(SwiftUI)
import SwiftUI
#endif

public extension UIViewController {
    
#if canImport(SwiftUI)
    private struct Preview: UIViewControllerRepresentable {
        let viewController: UIViewController

        func makeUIViewController(context: Context) -> UIViewController {
            return viewController
        }

        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    }

    func preview() -> some View {
        Preview(viewController: self)
    }
#endif

    var safeAreaInsets: UIEdgeInsets {
        UIApplication.shared.safeAreaInsets
    }

    var deviceWidthSize: CGFloat {
        return UIScreen.main.bounds.size.width
    }

    func addChildVC(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    func removeChildVC() {
        // Just to be safe, we check that this view controller
        // is actually added to a parent before removing it.
        guard parent != nil else { return }

        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }

    /**
     화면 터치할 때 키보드 내리기
     */
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = true
        view.addGestureRecognizer(tap)
    }

    /**
     화면 터치할 때 키보드 내리기
     */
    func hideKeyboardWhenTappedAround(_ targetView: UIView) {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        targetView.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        closeKeyboard()
    }
    
    func closeKeyboard() {
        view.endEditing(true)
    }

    func keyboardHeight() -> AnyPublisher<CGFloat,Never> {
        Publishers.Merge (
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
                .map{($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0},
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in CGFloat(0) }
        ).eraseToAnyPublisher()
    }

    func showActivityViewController(activityItems: [Any], sourceRect: CGRect, animated: Bool = false, completion: (() -> Void)? = nil) {
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        if #available(iOS 13.2, *) {
            activityVC.popoverPresentationController?.sourceRect = sourceRect
        }
        self.present(activityVC, animated: animated, completion: completion)
    }
}
