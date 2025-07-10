//
//  UIImageView+Extension.swift
//  CommonUtils
//
// Created by Dongju Lim on 11/13/24.
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

    func setUrlImage(
        _ urlStr: String,
        placeholder: UIImage? = nil,
        options: KingfisherOptionsInfo? = [ .transition(.fade(0.5))],
        imageResize: CGSize? = nil,
        isIndicator: Bool = true,
        indicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .medium)
    ) {
        internalSetUrlImage(
            urlStr,
            placeholder: placeholder,
            options: options,
            imageResize: imageResize,
            isIndicator: isIndicator,
            indicator: indicator,
            completionHandler: nil
        )
    }

    func setUrlImage(
        _ urlStr: String,
        placeholder: UIImage? = nil,
        options: KingfisherOptionsInfo? = [ .transition(.fade(0.5))],
        imageResize: CGSize? = nil,
        isIndicator: Bool = true,
        indicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .medium),
        completionHandler: @escaping ((Result<RetrieveImageResult, KingfisherError>) -> Void)
    ) {
        internalSetUrlImage(
            urlStr,
            placeholder: placeholder,
            options: options,
            imageResize: imageResize,
            isIndicator: isIndicator,
            indicator: indicator,
            completionHandler: completionHandler
        )
    }

    private func internalSetUrlImage(
        _ urlStr: String,
        placeholder: UIImage?,
        options: KingfisherOptionsInfo?,
        imageResize: CGSize?,
        isIndicator: Bool,
        indicator: UIActivityIndicatorView,
        completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)?
    ) {

        // 이미지 초기화 및 다운로드 취소
        self.stopDownloadTask()
        if let placeholder = placeholder, self.image == nil {
            self.image = placeholder
        }

        guard let url = URL(string: urlStr) else {
            self.image = nil
            completionHandler?(.failure(KingfisherError.requestError(reason: .emptyRequest)))
            return
        }

        var kfOptions = options ?? []

        if let resize = imageResize, resize.width > 0, resize.height > 0 {
            let processor = DownsamplingImageProcessor(size: resize)
            kfOptions.append(.processor(processor))
            kfOptions.append(.scaleFactor(UIScreen.main.scale))
            kfOptions.append(.cacheOriginalImage)
        }

        self.kf.indicatorType = isIndicator ? .custom(indicator: CustomKfActivityIndicator(indicator)) : .none
        if isIndicator {
            self.kf.indicator?.startAnimatingView()
        }

        // 🌄 이미지 로드 시작
        self.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: kfOptions
        ) { [weak self] result in
            // ✅ 인디케이터 중단
            self?.kf.indicator?.stopAnimatingView()
            completionHandler?(result)
        }
    }
#endif
}
