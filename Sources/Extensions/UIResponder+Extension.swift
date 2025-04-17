//
//  UIResponder+Extension.swift
//
//
// Created by Dongju Lim on 4/24/24.
//

import UIKit

// https://www.swiftdevcenter.com/access-view-controller-from-any-view-swift-5/
public extension UIResponder {
    func getOwningViewController() -> UIViewController? {
        var nextResponser = self
        while let next = nextResponser.next {
            nextResponser = next
            if let viewController = nextResponser as? UIViewController {
                return viewController
            }
        }
        return nil
    }

    @objc func openURL(_ url: URL) -> Bool {
        var nextResponser: UIResponder = self
        while let next = nextResponser.next {
            nextResponser = next
            if let application = nextResponser as? UIApplication {
                return (application.perform(#selector(openURL(_:)), with: url) != nil)
            }
        }
        return false
    }
}
