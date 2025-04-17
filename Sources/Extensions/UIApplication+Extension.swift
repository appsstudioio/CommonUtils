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
            guard self.shared.windows.count > 0 else { return nil }
            return self.shared.windows.first { $0.isKeyWindow }
        } else {
            return self.shared.keyWindow
        }
    }

    var windowScene: UIWindowScene? {
        return self.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first
    }

    var statusBar: CGRect {
        return self.windowScene?.statusBarManager?.statusBarFrame ?? .zero
    }

    var safeAreaInsets: UIEdgeInsets {
        if let insets = UIApplication.shared.windows.first?.safeAreaInsets {
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
        return UIApplication.shared.canOpenURL(URL(string: url)!)
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
        if self.canOpenUrl(url) {
            application.open(URL(string: url)!, options: [:]) { isSuccess in
                completion?(isSuccess)
            }
        } else {
            completion?(false)
        }
    }
}
