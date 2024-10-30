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
}

// https://github.com/kiritmodi2702/GIF-Swift/blob/master/GIF-Swift/iOSDevCenters%2BGIF.swift
public extension UIImage {

    class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            DebugLog("image doesn't exist")
            return nil
        }

        return UIImage.animatedImageWithSource(source)
    }

    class func gifImageWithURL(_ gifUrl:String) -> UIImage? {
        guard let bundleURL = URL(string: gifUrl),
                let imageData = try? Data(contentsOf: bundleURL) else {
            DebugLog("image named \"\(gifUrl)\" into NSData")
            return nil
        }
        return gifImageWithData(imageData)
    }

    class func gifImageWithName(_ name: String) -> UIImage? {
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
            DebugLog("SwiftGif: This image named \"\(name)\" does not exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            DebugLog("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }

        return gifImageWithData(imageData)
    }

    class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1

        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(
            CFDictionaryGetValue(cfProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()),
            to: CFDictionary.self)

        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }

        delay = delayObject as! Double

        if delay < 0.1 {
            delay = 0.1
        }

        return delay
    }

    class func gcdForPair(_ ia: Int?, _ ib: Int?) -> Int {
        guard let ia = ia, let ib = ib else {
            if ib != nil {
                return ib ?? 0
            } else if ia != nil {
                return ia ?? 0
            } else {
                return 0
            }
        }
        var a = ia
        var b = ib

        if a < b {
            let c = a
            a = b
            b = c
        }

        var rest: Int
        while true {
            rest = a % b
            if rest == 0 {
                return b
            } else {
                a = b
                b = rest
            }
        }
    }

    class func gcdForArray(_ array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }

        var gcd = array[0]

        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }

        return gcd
    }

    class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()

        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }

            let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
                source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }

        let duration: Int = {
            var sum = 0

            for val: Int in delays {
                sum += val
            }

            return sum
        }()

        let gcd = gcdForArray(delays)
        var frames = [UIImage]()

        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)

            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }

        let animation = UIImage.animatedImage(with: frames,
            duration: Double(duration) / 1000.0)

        return animation
    }
}
