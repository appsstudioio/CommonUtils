//
//  UIButton+Extension.swift
//
//
// Created by Dongju Lim on 2023/06/14.
//

import UIKit

public extension UIButton {
    func setBackgroundColor(_ color: UIColor?,
                            for state: UIControl.State,
                            alpha: CGFloat = 1.0) {

        let backgroundImage = UIImage.colorToBackgroundImage((color ?? .clear), alpha: alpha)
        self.setBackgroundImage(backgroundImage, for: state)
    }
    
    func underlineText(titleColor : UIColor? , font : UIFont) {
        guard let title = title(for: .normal), let titleColor = titleColor else { return }
        
        let titleString = NSMutableAttributedString(string: title)
        let titleLength = (title as NSString).length
        titleString.addAttribute(
            .underlineStyle,
            value: NSUnderlineStyle.single.rawValue,
            range: NSRange(location: 0, length: titleLength)
        )
        
        titleString.addAttribute(NSAttributedString.Key.foregroundColor, value: titleColor, range: NSRange(location: 0, length: titleLength))
        titleString.addAttribute(NSAttributedString.Key.font, value: font, range: NSRange(location: 0, length: titleLength))
        setAttributedTitle(titleString, for: .normal)
    }
    
    // https://developer-eungb.tistory.com/30
    func alignTextBelow(spacing: CGFloat = 4.0) {
        guard let image = self.imageView?.image else {
            return
        }

        guard let titleLabel = self.titleLabel else {
            return
        }

        guard let titleText = titleLabel.text else {
            return
        }

        let titleSize = titleText.size(withAttributes: [
            NSAttributedString.Key.font: titleLabel.font as Any
        ])

        titleEdgeInsets = UIEdgeInsets(top: spacing, left: -image.size.width, bottom: -image.size.height, right: 0)
        imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: 0, bottom: 0, right: -titleSize.width)
    }
}

public extension UIBarButtonItem {
    static func createUIBarButtonItem(image: UIImage?,
                                      target: Any,
                                      action: Selector,
                                      buttonSize: CGFloat = 26) -> UIBarButtonItem {
        if CommonNavigationAppearance.usesSystemButtons {
            let item = UIBarButtonItem(image: navigationImage(image), style: .plain, target: target, action: action)
            item.tintColor = CommonNavigationAppearance.buttonTintColor
            return item
        }
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.plain()
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            button.configuration = configuration
        }
        button.tintColor = .white
        button.frame = CGRectMake(0, 0, buttonSize, buttonSize)
        return UIBarButtonItem(customView: button)
    }
    
    static func createUIBarButtonItem(image: UIImage?,
                                      menu: UIMenu,
                                      buttonSize: CGFloat = 26) -> UIBarButtonItem {
        if CommonNavigationAppearance.usesSystemButtons {
            let item = UIBarButtonItem(image: navigationImage(image), menu: menu)
            item.tintColor = CommonNavigationAppearance.buttonTintColor
            return item
        }
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        if #available(iOS 14.0, *) {
            button.menu = menu
        }
        button.overrideUserInterfaceStyle = .unspecified
        if #available(iOS 14.0, *) {
            button.showsMenuAsPrimaryAction = true
        }
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.plain()
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            button.configuration = configuration
        }
        button.tintColor = .white
        button.frame = CGRectMake(0, 0, buttonSize, buttonSize)
        return UIBarButtonItem(customView: button)
    }

    private static func navigationImage(_ image: UIImage?) -> UIImage? {
        return image?.centeredNavigationIcon().withRenderingMode(.alwaysTemplate)
    }

    static func buttonToBarButtonItem(_ button: UIButton) -> UIBarButtonItem {
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.plain()
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            button.configuration = configuration
        }
        if CommonNavigationAppearance.usesSystemButtons {
            button.tintColor = CommonNavigationAppearance.buttonTintColor
            for state: UIControl.State in [.normal, .selected, .highlighted, .disabled] {
                if let image = button.image(for: state) {
                    button.setImage(navigationImage(image), for: state)
                }
            }
        }
        return UIBarButtonItem(customView: button)
    }
}
