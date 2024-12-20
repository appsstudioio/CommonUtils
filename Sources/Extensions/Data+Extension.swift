//
//  Data+Extension.swift
//
//
//  Created by 10-N3344 on 8/12/24.
//

import Foundation
import ImageIO

public extension Data {
    var toJsonDic: [String: Any?]? {
        do {
            return try JSONSerialization.jsonObject(with: self, options: []) as? [String: Any?]
        } catch {
            DebugLog("!!!! toJsonDic Error :: \(error.localizedDescription)", level: .error)
            return nil
        }
    }

    var toJsonStrng: String? {
        return String(data: self, encoding: .utf8)
    }

    var mimeType: MimeType? {
        if self.getImageMimeType()?.lowercased().hasSuffix("heic") ?? false {
            return MimeType.all.filter({ $0.type == .heic }).first
        }
        return Swime.mimeType(data: self)
    }

    func getImageMimeType() -> String? {
        guard let source = CGImageSourceCreateWithData(self as CFData, nil),
              let type = CGImageSourceGetType(source) else {
            return nil
        }
        return type as String
    }

    // https://gist.github.com/siempay/1dd2af4ccc06cea2858ced27d0988c21
    var toBytes: Int64 {
        .init(self.count)
    }

    var kilobytes: Double {
        return Double(toBytes) / 1_024
    }

    var megabytes: Double {
        return kilobytes / 1_024
    }

    var gigabytes: Double {
        return megabytes / 1_024
    }

    func getReadableUnit() -> String {
        let bytes = toBytes
        switch bytes {
            case 0..<1_024:
                return "\(bytes)B" // bytes
            case 1_024..<(1_024 * 1_024):
                return "\(String(format: "%4.2f", kilobytes))KB"
            case 1_024..<(1_024 * 1_024 * 1_024):
                return "\(String(format: "%4.2f", megabytes))MB"
            case (1_024 * 1_024 * 1_024)...Int64.max:
                return "\(String(format: "%.2f", gigabytes))GB"
            default:
                return "\(bytes)B"
        }
    }
}
