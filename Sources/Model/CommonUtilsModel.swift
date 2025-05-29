//
//  CommonUtilsModel.swift
//  CommonUtils
//
// Created by Dongju Lim on 10/30/24.
//
import Kingfisher
import ProgressHUD
import UIKit

public struct CommonKingfisherConfig {
    /// Total cost limit of the storage in bytes. Limit memory cache size to 200 MB.(200 * 1024 * 1024)
    public var memoryStorageTotalCostLimit: Int
    /// The item count limit of the memory storage.
    public var memoryStorageCountLimit: Int
    /// The file size limit on disk of the storage in bytes. 0 means no limit. disk cache size to 2 GB
    public var diskStorageSizeLimit: UInt
    public var diskStorageExpiration: StorageExpiration
    public var memoryStorageExpiration: StorageExpiration

    public init(memoryStorageTotalCostLimit: Int = 200 * 1024 * 1024,
                memoryStorageCountLimit: Int = 10,
                diskStorageSizeLimit: UInt = 2000 * 1024 * 1024,
                diskStorageExpiration: StorageExpiration = .days(14),
                memoryStorageExpiration: StorageExpiration = .seconds(300)) {
        self.memoryStorageTotalCostLimit = memoryStorageTotalCostLimit
        self.memoryStorageCountLimit = memoryStorageCountLimit
        self.diskStorageSizeLimit = diskStorageSizeLimit
        self.diskStorageExpiration = diskStorageExpiration
        self.memoryStorageExpiration = memoryStorageExpiration
    }
}

public struct CommonProgressHUDConfig {
    public var animationType: AnimationType
    public var colorHUD: UIColor
    public var colorBackground: UIColor
    public var colorProgress: UIColor
    public var colorAnimation: UIColor
    public var colorStatus: UIColor
    public var fontStatus: UIFont

    public init(animationType: AnimationType = .circleStrokeSpin,
                colorHUD: UIColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4),
                colorBackground: UIColor = UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 0.15),
                colorProgress: UIColor = UIColor(red: 49/255, green: 136/255, blue: 244/255, alpha: 1.0),
                colorAnimation: UIColor = UIColor(red: 49/255, green: 136/255, blue: 244/255, alpha: 1.0),
                colorStatus: UIColor = .label,
                fontStatus: UIFont = UIFont.systemFont(ofSize: 16, weight: .semibold)) {
        self.animationType = animationType
        self.colorHUD = colorHUD
        self.colorBackground = colorBackground
        self.colorProgress = colorProgress
        self.colorAnimation = colorAnimation
        self.colorStatus = colorStatus
        self.fontStatus = fontStatus
    }
}

public struct CommonUtilVideoInfo {
    let duration: Double
    let resolution: CGSize?
    let frameRate: Float?
    let bitRate: Float?
    let videoCodec: String?
    let audioCodec: String?
    let audioSampleRate: Float64?
    let audioChannels: Int?
}

public enum CommonUtilCompressionError: Error {
    case exportSessionFailure(String)
    case unknownError
    case minimumQualityExceedsMaxFileSize(Int64)
}

// 압축 품질 설정
public enum CommonUtilCompressionQuality {
    case low
    case medium
    case high
    case original

    // 원본 비트레이트 대비 압축 비율 (%)
    var compressionRatio: Float {
        switch self {
        case .low: return 0.5     // 원본의 50%
        case .medium: return 0.7  // 원본의 70%
        case .high: return 0.9    // 원본의 90%
        case .original: return 1.0  // 원본의 100%
        }
    }

    // 최소 비트레이트 보장 (화질 저하 방지)
    var minimumBitRate: Float {
        switch self {
        case .low: return 1_000_000    // 최소 1 Mbps
        case .medium: return 2_000_000 // 최소 2 Mbps
        case .high: return 3_000_000   // 최소 3 Mbps
        case .original: return 4_000_000   // 최소 4 Mbps
        }
    }
}
