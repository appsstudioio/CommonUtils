//
//  UIResponder+Extension.swift
//
//
//  Created by 10-N3344 on 4/24/24.
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
}
