//
//  UIViewController+Extension.swift
//
//
// Created by Dongju Lim on 8/13/24.
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
        )
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
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

public extension UIViewController {

    func hideNavigationLeftButton(hidden: Bool, target: Any? = nil, action: Selector? = nil){
        if hidden {
            self.navigationItem.setLeftBarButton(nil, animated: true)
        } else {
            var backImage: UIImage? = UIImage(named: "actionbar_btn_back", in: Bundle.module, with: nil)?.withRenderingMode(.alwaysTemplate)
            if (self.presentingViewController != nil) {
                if navigationController?.viewControllers.count == 1 || navigationController == nil {
                    backImage = UIImage(named: "actionbar_btn_close", in: Bundle.module, with: nil)?.withRenderingMode(.alwaysTemplate)
                }
            } else if navigationController?.viewControllers.count == 1 || navigationController == nil {
                backImage = UIImage(named: "actionbar_btn_close", in: Bundle.module, with: nil)?.withRenderingMode(.alwaysTemplate)
            }
            
            navigationItem.hidesBackButton = true
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: backImage?.resized(to: CGSize(width: 24, height: 24)),
                style: .plain,
                target: target,
                action: action
            )
        }
    }

    func hideNavigationRightButton(hidden: Bool,
                                   image: UIImage? = nil,
                                   target: Any? = nil,
                                   action: Selector? = nil){
        if hidden {
            self.navigationItem.setRightBarButton(nil, animated: true)
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: image?.resized(to: CGSize(width: 24, height: 24)),
                style: .plain,
                target: target,
                action: action
            )
        }
    }

    func hideNavigationLeftButton(hidden: Bool, button: UIButton, buttonSize: CGSize) {
        if hidden {
            self.navigationItem.setLeftBarButton(nil, animated: true)
        } else {
            button.frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height)
            navigationItem.leftBarButtonItem = UIBarButtonItem.buttonToBarButtonItem(button)
        }
    }

    func hideNavigationRightButton(hidden: Bool, button: UIButton, buttonSize: CGSize) {
        if hidden {
            self.navigationItem.setRightBarButton(nil, animated: true)
        } else {
            button.frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height)
            navigationItem.rightBarButtonItem = UIBarButtonItem.buttonToBarButtonItem(button)
        }
    }

    func setNavigationBarTitle(_ titleText: String = "") {
        DispatchQueue.main.async { [weak self] in
            // 빈 문자열을 설정하지 않도록 방어 코드 추가
            self?.navigationItem.title = titleText.isEmpty ? nil : titleText
        }
    }

    func hideNavigationBar(hidden: Bool, animate: Bool = true, titleText: String = "") {
        DispatchQueue.main.async { [weak self] in
            // NavigationBar 숨기기
            self?.navigationController?.setNavigationBarHidden(hidden, animated: animate)
            // NavigationBar가 숨겨지지 않았을 때만 타이틀 설정
            if !hidden, !titleText.isEmpty {
                self?.navigationItem.title = titleText.isEmpty ? nil : titleText
            }
        }
    }

    func hideNavigationBar(hidden: Bool, animate: Bool = true) {
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.setNavigationBarHidden(hidden, animated: animate)
        }
    }

    func presentView(_ viewVC: UIViewController,
                     modalStyle: UIModalPresentationStyle = .overFullScreen,
                     animated: Bool = true) {
        viewVC.modalPresentationStyle = modalStyle
        self.present(viewVC, animated: animated)
    }

    func pushView(_ moveVC: UIViewController, animated: Bool = true) {
        self.navigationController?.pushViewController(moveVC, animated: animated)
    }

    func popView(animated: Bool = true) {
        self.navigationController?.popViewController(animated: animated)
    }

    func dismissModalView(_ animated: Bool = true) {
        self.dismiss(animated: animated)
    }

    func dismissAllControllers(_ animated: Bool = true) {
        guard let rootVC = UIApplication.key?.rootViewController else { return }
        rootVC.dismiss(animated: animated, completion: nil)
    }

    @objc func moveBack(_ animated: Bool = true) {
        if self.presentingViewController != nil {
            if navigationController?.viewControllers.count == 1 || navigationController == nil {
                self.dismissModalView(animated)
                return
            }
        }
        self.popView(animated: animated)
    }

}
