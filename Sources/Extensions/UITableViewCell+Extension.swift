//
//  UITableViewCell+Extension.swift
//
//
//  Created by 10-N3344 on 2023/06/14.
//

import UIKit

public extension UITableViewCell {
    static var identifier: String {
        return String(describing: self)
    }
    
    var tableView: UITableView? {
        var view = self.superview
        while view != nil && view!.isKind(of: UITableView.self) == false {
            view = view!.superview
        }
        return view as? UITableView
    }
}

public extension UITableViewHeaderFooterView {
    static var identifier: String {
        return String(describing: self)
    }
}

public extension UICollectionViewCell {
    static var identifier: String {
        return String(describing: self)
    }
}
