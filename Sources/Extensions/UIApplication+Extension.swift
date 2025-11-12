//
//  UIApplication+Extension.swift
//
//
// Created by Dongju Lim on 2023/06/14.
//

import UIKit

public extension UIApplication {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .flatMap { $0.windows }
                    .first(where: { $0.isKeyWindow })
        } else {
            return self.shared.keyWindow
        }
    }

    var windowScene: UIWindowScene? {
        return self.connectedScenes
            .first { $0.activationState == .foregroundActive }
            .flatMap { $0 as? UIWindowScene }
    }

    static var sceneDelegate: UISceneDelegate? {
        UIApplication.shared.connectedScenes
            .first { $0.activationState == .foregroundActive }?
            .delegate as? UISceneDelegate
    }

    var statusBar: CGRect {
        return self.windowScene?.statusBarManager?.statusBarFrame ?? .zero
    }

    var safeAreaInsets: UIEdgeInsets {
        if let insets = UIApplication.key?.safeAreaInsets {
            return insets
        } else {
            return .zero
        }
    }
    
    func topViewController(base: UIViewController? = UIApplication.key?.rootViewController) -> UIViewController? {
        if base is UITabBarController {
            let control = base as? UITabBarController
            return topViewController(base: control?.selectedViewController)
        } else if base is UINavigationController {
            let control = base as? UINavigationController
            return topViewController(base: control?.visibleViewController)
        } else if let control = base?.presentedViewController {
            return topViewController(base: control)
        }
        return base
    }
    
    func canOpenUrl(_ url: String) -> Bool {
        guard let url = URL(string: url) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }

    func tryURL(urls: [String]) {
        for url in urls {
            if self.canOpenUrl(url) {
                self.openURL(url: url)
                return
            }
        }
    }

    func openURL(url: String, completion: ((Bool) -> Void)? = nil) {
        let application = UIApplication.shared
        guard let link = URL(string: url), application.canOpenURL(link) else {
            completion?(false)
            return
        }
        application.open(link, options: [:]) { isSuccess in
            completion?(isSuccess)
        }
    }
}
