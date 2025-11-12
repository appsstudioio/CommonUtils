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
        self.image = nil
        kf.cancelDownloadTask()
    }

    func setUrlImage(
        _ urlStr: String,
        placeholder: UIImage? = nil,
        options: KingfisherOptionsInfo? = [ .transition(.none)],
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
        options: KingfisherOptionsInfo? = [ .transition(.none)],
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
        stopDownloadTask()
        if let placeholder = placeholder, image == nil {
            image = placeholder
        }

        guard let url = URL(string: urlStr) else {
            DebugLog("internalSetUrlImage urlStr is not valid url", level: .error, param: ["urlStr": urlStr])
            image = nil
            completionHandler?(.failure(KingfisherError.requestError(reason: .emptyRequest)))
            return
        }

        // 기존에 존재할 수 있는 커스텀 인디케이터 뷰를 제거하여 오토 레이아웃 충돌을 방지합니다.
        kf.indicator?.view.removeFromSuperview()
        var kfOptions = options ?? []

        // ✅ 리사이즈 적용 (없으면 imageView 크기 사용)
        let targetSize: CGSize
        if let resize = imageResize, resize.width > 0, resize.height > 0 {
            targetSize = resize
        } else {
            targetSize = bounds.size // 뷰 크기 기준으로 다운샘플링
        }

        var resizedCacheKey = url.absoluteString
        if targetSize.width > 0 && targetSize.height > 0 {
            let processor = DownsamplingImageProcessor(size: targetSize)
            kfOptions.append(.processor(processor))
            kfOptions.append(.scaleFactor(UIScreen.main.scale))
            // ✅ 해상도별 cacheKey 생성
            let sizeKey = "w\(Int(targetSize.width))_h\(Int(targetSize.height))"
            resizedCacheKey = "\(url.absoluteString)_\(sizeKey)"
        }

        kf.indicatorType = isIndicator ? .custom(indicator: CustomKfActivityIndicator(indicator)) : .none
        if isIndicator {
            kf.indicator?.startAnimatingView()
        }

        let resource = KF.ImageResource(
            downloadURL: url,
            cacheKey: resizedCacheKey
        )

        // 🌄 이미지 로드 시작
        kf.setImage(
            with: resource,
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
