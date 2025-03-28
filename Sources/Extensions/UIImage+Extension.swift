//
//  UIImage+Extension.swift
//
//
//  Created by 10-N3344 on 2023/09/01.
//

import Foundation
import UIKit

public extension UIImage {
    static func getSFSymbolImage(name: String, size: CGFloat, weight: UIImage.SymbolWeight, color: UIColor) -> UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: size, weight: weight)
        let image = UIImage(systemName: name, withConfiguration: config)?.withTintColor(color)
        return image?.withRenderingMode(.alwaysOriginal)
    }
    
    // 출처: https://khstar.tistory.com/entry/Swift-UIImage-사이즈-조절하기 [khstar:티스토리]
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: self.size.width * percentage, height: self.size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }

    class func colorToBackgroundImage(_ color: UIColor, alpha: CGFloat = 1.0) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        context!.setAlpha(alpha)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }

    func imageWithImage(scaledToWidth: CGFloat) -> UIImage {
        let oldWidth = self.size.width
        let scaleFactor = scaledToWidth / oldWidth

        let newHeight = self.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor

    //    UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: newHeight), false, (UIScreen.main.scale * 2))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
    }

    func imageWithImage(scaledToHeight: CGFloat) -> UIImage {
        let oldHeight = self.size.height
        let scaleFactor = scaledToHeight / oldHeight

        let newWidth = self.size.width * scaleFactor
        let newHeight = oldHeight * scaleFactor

    //    UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: newHeight), false, (UIScreen.main.scale * 2))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
    }

    // MARK: Image 에 Alpha 값 적용
    func imageWithAlpha(alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: .zero, blendMode: .normal, alpha: alpha)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    /*
    카메라로 찍은 사진에서 방향이 다르게 저장되는 문제는 UIImage의 orientation 속성 때문입니다.
    카메라로 촬영된 이미지는 사진의 메타데이터에 방향 정보(orientation)가 포함되는데, 이를 제대로 처리하지 않으면 사진이 잘못된 방향으로 표시될 수 있습니다.

    이 문제는 특히 UIImagePickerController를 사용할 때 자주 발생합니다.
    iOS 카메라가 사진의 원본 파일을 저장할 때, 파일 자체는 회전되지 않고, 대신 EXIF메타데이터에 사진의 방향 정보가 포함됩니다.
    하지만 이 메타데이터를 무시하면 사진이 잘못된 방향으로 표시될 수 있습니다.
    카메라로 찍은 이미지의 방향이 잘못된 경우, 위의 fixOrientation(image:) 메서드를 사용하여 이미지를 정상 방향으로 수정
     */
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }

        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(origin: .zero, size: self.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return normalizedImage ?? self
    }

    func withBackgroundColor(_ backgroundColor: UIColor, borderColor: UIColor, borderWidth: CGFloat, cornerRadius: CGFloat) -> UIImage? {
        let size = self.size
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size.width + borderWidth * 2, height: size.height + borderWidth * 2))

        let imageWithBackground = renderer.image { context in
            let rect = CGRect(origin: .zero, size: CGSize(width: size.width + borderWidth * 2, height: size.height + borderWidth * 2))

            // 둥근 테두리 그리기
            let path = UIBezierPath(roundedRect: rect.insetBy(dx: borderWidth / 2, dy: borderWidth / 2), cornerRadius: cornerRadius)

            // 배경 색상 채우기 (보더 포함)
            backgroundColor.setFill()
            path.fill()

            // 보더 색상 그리기
            borderColor.setStroke()
            context.cgContext.setLineWidth(borderWidth)
            path.stroke()

            // 이미지 그리기 (보더 안쪽으로 둥글게 처리된 부분)
            let imageRect = CGRect(x: borderWidth, y: borderWidth, width: size.width, height: size.height)
            let imagePath = UIBezierPath(roundedRect: imageRect, cornerRadius: cornerRadius - borderWidth)
            imagePath.addClip()  // 둥근 테두리 안에만 이미지 그리기
            self.draw(in: imageRect)
        }

        return imageWithBackground
    }

    // MARK: 이미지 돌아갔을 경우 원복
    func fixedOrientation() -> UIImage {
        // 정상일 경우
        if (imageOrientation == Orientation.up) {
            return self
        }

        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform:CGAffineTransform = CGAffineTransform.identity

        if (imageOrientation == Orientation.down || imageOrientation == Orientation.downMirrored) {
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
        }

        if (imageOrientation == Orientation.left
            || imageOrientation == Orientation.leftMirrored) {

            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2)
        }

        if (imageOrientation == Orientation.right
            || imageOrientation == Orientation.rightMirrored) {

            transform = transform.translatedBy(x: 0, y: size.height);
            transform = transform.rotated(by: -CGFloat.pi / 2);
        }

        if (imageOrientation == Orientation.upMirrored
            || imageOrientation == Orientation.downMirrored) {

            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }

        if (imageOrientation == Orientation.leftMirrored
            || imageOrientation == Orientation.rightMirrored) {

            transform = transform.translatedBy(x: size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
        }

        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx:CGContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height),
                                      bitsPerComponent: cgImage!.bitsPerComponent, bytesPerRow: 0,
                                      space: cgImage!.colorSpace!,
                                      bitmapInfo: cgImage!.bitmapInfo.rawValue)!

        ctx.concatenate(transform)

        if (imageOrientation == Orientation.left
            || imageOrientation == Orientation.leftMirrored
            || imageOrientation == Orientation.right
            || imageOrientation == Orientation.rightMirrored
        ) {

            ctx.draw(cgImage!, in: CGRect(x:0,y:0,width:size.height,height:size.width))
        } else {
            ctx.draw(cgImage!, in: CGRect(x:0,y:0,width:size.width,height:size.height))
        }

        // And now we just create a new UIImage from the drawing context
        let cgimg:CGImage = ctx.makeImage()!
        let imgEnd:UIImage = UIImage(cgImage: cgimg)

        return imgEnd
    }
}

public extension UIImage {
    /// GIF 이미지 데이터를 UIImage로 변환하는 메서드
    /// - Parameter data: GIF 이미지 데이터
    /// - Returns: 첫 번째 프레임의 UIImage 또는 nil
    static func fromGifData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }

        let imageCount = CGImageSourceGetCount(source)
        guard imageCount > 0 else {
            return nil
        }

        // 첫 번째 프레임 가져오기
        guard let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    /// GIF 이미지 데이터를 애니메이션 UIImage로 변환하는 메서드
    /// - Parameters:
    ///   - data: GIF 이미지 데이터
    ///   - scale: 이미지 스케일 (기본값: 화면의 스케일)
    /// - Returns: 애니메이션 UIImage 또는 nil
    static func animatedImageFromGifData(_ data: Data, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }

        let imageCount = CGImageSourceGetCount(source)
        guard imageCount > 0 else {
            return nil
        }

        var images: [UIImage] = []
        var duration: TimeInterval = 0

        for index in 0..<imageCount {
            // CGImage 생성
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil) else {
                continue
            }

            // 각 프레임의 지속 시간 가져오기
            guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [String: Any],
                  let gifProperties = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any] else {
                continue
            }

            let frameDuration = gifProperties[kCGImagePropertyGIFDelayTime as String] as? TimeInterval ?? 0.1
            duration += frameDuration

            // UIImage 생성
            let uiImage = UIImage(cgImage: cgImage, scale: scale, orientation: .up)
            images.append(uiImage)
        }

        return UIImage.animatedImage(with: images, duration: duration)
    }
}
