//
//  UIImageView+Extension.swift
//  CommonUtils
//
//  Created by 10-N3344 on 11/13/24.
//
import UIKit
#if canImport(Kingfisher)
import Kingfisher
#endif

public class CustomKfActivityIndicator: Indicator {
    public let view: UIView

    public init(_ activityIndicator: UIActivityIndicatorView) {
        self.view = activityIndicator
    }

    public func startAnimatingView() { (view as? UIActivityIndicatorView)?.startAnimating() }
    public func stopAnimatingView() { (view as? UIActivityIndicatorView)?.stopAnimating() }
}

public extension UIImageView {
#if canImport(Kingfisher)
    func stopDownloadTask() {
        self.kf.cancelDownloadTask()
    }

    func setUrlImage(_ urlStr: String,
                     placeholder: UIImage? = nil,
                     options: KingfisherOptionsInfo? = [ .transition(.fade(0.5))],
                     imageResize: CGSize? = nil,
                     isIndicator: Bool = true,
                     indicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .medium)) {
        guard let url = URL(string: urlStr) else {
            self.image = nil
            return
        }

        var kfOptions = options
        if let resize = imageResize {
            // let resizeProcessor = ResizingImageProcessor(referenceSize: resize, mode: .aspectFill)
            let processor = DownsamplingImageProcessor(size: resize)
            // kfOptions?.append(.forceTransition)
            kfOptions?.append(.processor(processor))
            kfOptions?.append(.scaleFactor(UIScreen.main.scale))
            kfOptions?.append(.cacheOriginalImage)
        }

        self.kf.indicatorType = (isIndicator ? .custom(indicator: CustomKfActivityIndicator(indicator)) : .none)
        if isIndicator {
            self.kf.indicator?.startAnimatingView()
        }

        self.kf.setImage(with: url, placeholder: placeholder, options: kfOptions)
    }

    func setUrlImage(_ urlStr: String,
                     placeholder: UIImage? = nil,
                     options: KingfisherOptionsInfo? = [ .transition(.fade(0.5))],
                     imageResize: CGSize? = nil,
                     isIndicator: Bool = true,
                     indicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .medium),
                     completionHandler: @escaping ((Result<RetrieveImageResult, KingfisherError>) -> Void)) {
        guard let url = URL(string: urlStr) else {
            self.image = nil
            return
        }

        var kfOptions = options
        if let resize = imageResize {
            // let resizeProcessor = ResizingImageProcessor(referenceSize: resize, mode: .aspectFill)
            let processor = DownsamplingImageProcessor(size: resize)
            // kfOptions?.append(.forceTransition)
            kfOptions?.append(.processor(processor))
            kfOptions?.append(.scaleFactor(UIScreen.main.scale))
            kfOptions?.append(.cacheOriginalImage)
        }

        self.kf.indicatorType = (isIndicator ? .custom(indicator: CustomKfActivityIndicator(indicator)) : .none)
        if isIndicator {
            self.kf.indicator?.startAnimatingView()
        }

        self.kf.setImage(with: url,
                         placeholder: placeholder,
                         options: kfOptions) { [weak self] result in
            self?.kf.indicator?.stopAnimatingView()
            completionHandler(result)
        }
    }
#endif
}
