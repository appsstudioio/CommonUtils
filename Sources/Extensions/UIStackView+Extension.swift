//
//  UIStackView+Extension.swift
//
//
// Created by Dongju Lim on 10/25/23.
//

import UIKit

// https://gist.github.com/Deub27/5eadbf1b77ce28abd9b630eadb95c1e2
public extension UIStackView {
    func removeAllArrangedSubviews() {
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        // Deactivate all constraints
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}
