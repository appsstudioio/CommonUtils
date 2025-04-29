// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import SystemConfiguration
import os.log
import UIKit
import CoreTelephony
import Photos
import LocalAuthentication
#if canImport(Kingfisher)
import Kingfisher
#endif
#if canImport(ProgressHUD)
import ProgressHUD
#endif

public enum DebugLogLevel: String {
    case debug, info, error, log, trace, notice, warning, critical, fault
}

@available(iOS 14.0, *)
private var loggerCache = [String: Logger]()
private let loggerQueue = DispatchQueue(label: "debug.log.queue")

@available(iOS 14.0, *)
private func getLogger(subsystem: String, category: String) -> Logger {
    let key = "\(subsystem)_\(category)"
    return loggerQueue.sync {
        if let cached = loggerCache[key] {
            return cached
        } else {
            let newLogger = Logger(subsystem: subsystem, category: category)
            loggerCache[key] = newLogger
            return newLogger
        }
    }
}

public func DebugLog(_ message: Any? = "",
                     level: DebugLogLevel = .info,
                     file: String = #file,
                     funcName: String = #function,
                     line: Int = #line,
                     param: [String: Any] = [:]) {
#if DEBUG
    let fileName: String = (file as NSString).lastPathComponent
    var fullMessage = """
    [파일: \(fileName), 라인: \(line), 함수: \(funcName)]
    \(String(describing: message))
    """

    if !param.isEmpty {
        fullMessage += "\n[추가 정보: \(param.toJsonString)]"
    }


    if #available(iOS 14.0, *) {
        // Xcode15 로깅 기능 추가. https://ios-development.tistory.com/381
        let subsystem = CommonUtils.getBundleIdentifier
        let logger = getLogger(subsystem: subsystem, category: level.rawValue)
        switch level {
        case .debug:
            logger.debug("\(fullMessage)")
        case .info:
            logger.info("\(fullMessage)")
        case .error:
            logger.error("\(fullMessage)")
        case .fault:
            logger.fault("\(fullMessage)")
        case .log:
            logger.log("\(fullMessage)")
        case .trace:
            logger.trace("\(fullMessage)")
        case .notice:
            logger.notice("\(fullMessage)")
        case .warning:
            logger.warning("\(fullMessage)")
        case .critical:
            logger.critical("\(fullMessage)")
        }
    } else {
        debugPrint(fullMessage)
    }
#endif
}

public func showLoadingView(_ text: String? = nil, interaction: Bool = false) {
#if canImport(ProgressHUD)
    ProgressHUD.animate(text, interaction: interaction)
#endif
}

public func showProgressView(_ text: String? = nil, value: CGFloat, interaction: Bool = false) {
#if canImport(ProgressHUD)
    ProgressHUD.progress(text, value, interaction: interaction)
#endif
}

public func dismissLoadingView() {
#if canImport(ProgressHUD)
    ProgressHUD.dismiss()
#endif
}

public class CommonUtils {

    static public func getAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    static public var getAppName: String {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "UnknownAppName"
    }

    static public var getBundleIdentifier: String {
        return Bundle.main.bundleIdentifier ?? (Bundle.main.infoDictionary?["BundleIdentifier"] as? String ?? "UnknownBundle")
    }

    static public func getModel() -> String {
        return UIDevice.current.model
    }

    static public func getSystemVersion() -> String {
        return UIDevice.current.systemVersion
    }

    static public func getScreenScale() -> CGFloat {
        return UIScreen.main.scale
    }

    static public func getMobileCarrier() -> CTCarrier? {
        let networkInfo = CTTelephonyNetworkInfo()
        if let providers = networkInfo.serviceSubscriberCellularProviders {
            return providers.values.first
        }
        return nil
    }

    static public func resetAllNotificationsData() {
        // 알림 센터 초기화..
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        if #available(iOS 16.0, *) {
            UNUserNotificationCenter.current().setBadgeCount(0)
        } else {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }

    static public func getDocumentDirectory() -> String {
        var documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
        if !documentsDirectory.hasSuffix("/") {
            documentsDirectory = documentsDirectory.appending("/")
        }
        return documentsDirectory
    }

    static public func getFileSize(filePath: String) -> NSNumber {
        do {
            let fileItem = try FileManager.default.attributesOfItem(atPath: filePath)
            return (fileItem[FileAttributeKey.size] as? NSNumber) ?? 0
        } catch {
            DebugLog("!!!! getFileSize Error :: \(error.localizedDescription)")
            return 0
        }
    }
    
    //app stroe link to production
     static public func openAppStore(appStoreId: String) {
        UIApplication.shared.openURL(url: "https://apps.apple.com/kr/app/id\(appStoreId)")
    }

    static public func openSetting() {
        UIApplication.shared.openURL(url: UIApplication.openSettingsURLString)
    }

    // 앱스토어 버전 정보
    static public func getAppStoreVersion(appStoreId: String, completion: @escaping ((String?) -> Void)) {
         guard let url = URL(string: "https://itunes.apple.com/lookup?id=\(appStoreId)&country=kr") else {
             completion(nil)
             return
         }
         let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
             if let data = data {
                 do {
                     let jsonObject = try JSONSerialization.jsonObject(with: data)
                     guard let json = jsonObject as? [String: Any] else {
                         DebugLog("The received that is not a Dictionary")
                         completion(nil)
                         return
                     }
                     let results = json["results"] as? [[String: Any]]
                     let firstResult = results?.first
                     if let currentVersion = firstResult?["version"] as? String {
                         DebugLog("currentVersion :: \(currentVersion)")
                         completion(currentVersion)
                     }
                 } catch let serializationError {
                     DebugLog("Serialization Error: \(serializationError)")
                     completion(nil)
                 }
                 return
             } else if let error = error {
                 DebugLog("Error: \(error.localizedDescription)")
             } else if let response = response {
                 DebugLog("Response: \(response)")
             } else {
                 DebugLog("Unknown error")
             }
             completion(nil)
         }
         task.resume()
    }
    
    static public func createUrlPath(_ hostURL: String, path: String) -> URL? {
        var urlString = hostURL
        if !path.hasPrefix("/") && !hostURL.hasSuffix("/") && hostURL != "" {
            urlString += "/\(path)"
        } else {
            urlString += path
        }

        return URL(string: urlString)
    }

    // 동영상의 방향을 확인하고 반환하는 함수
    static public func fixVideoOrientation(asset: AVAsset) -> CGAffineTransform? {
        if let videoTrack = asset.tracks(withMediaType: .video).first {
            return videoTrack.preferredTransform
        }
        return nil
    }
}

// MARK: - Kingfisher, ProgressHUD Config
public extension CommonUtils {

    static func kingfisherConfig(_ config: CommonKingfisherConfig = CommonKingfisherConfig()) {
#if canImport(Kingfisher)
        /* Kingfisher Image Cache config */
        // Limit memory cache size to 200 MB.(200 * 1024 * 1024)
        ImageCache.default.memoryStorage.config.totalCostLimit = config.memoryStorageTotalCostLimit
        // Limit memory cache to hold 10 images at most.
        ImageCache.default.memoryStorage.config.countLimit     = config.memoryStorageCountLimit
        // Memory image expires after 1 minutes.
        ImageCache.default.memoryStorage.config.expiration     = config.memoryStorageExpiration

        // Limit disk cache size to 2 GB.
        ImageCache.default.diskStorage.config.sizeLimit        = config.diskStorageSizeLimit
        // Disk image never expires.
        ImageCache.default.diskStorage.config.expiration       = config.diskStorageExpiration
        // Remove only expired.
        ImageCache.default.cleanExpiredCache {
            DebugLog("cleanExpiredCache")
            ImageCache.default.calculateDiskStorageSize { result in
                switch result {
                case .success(let size):
                    DebugLog("======= Disk cache size: \(Double(size) / 1024 / 1024) MB")
                case .failure(let error):
                    DebugLog(error)
                }
            }
        }
#endif
    }

    static func progressHUDConfig(_ config: CommonProgressHUDConfig = CommonProgressHUDConfig()) {
#if canImport(ProgressHUD)
        ProgressHUD.animationType = config.animationType
        ProgressHUD.colorHUD = config.colorHUD
        ProgressHUD.colorBackground = config.colorBackground
        ProgressHUD.colorAnimation = config.colorAnimation
        ProgressHUD.colorProgress = config.colorProgress
        ProgressHUD.colorStatus = config.colorStatus
        ProgressHUD.fontStatus = config.fontStatus
#endif
    }
}

public extension CommonUtils {

    static func downloadUrlImage(_ hostURL: String, path: String, completionHandler: @escaping (UIImage?, Data?) -> Void) {
#if canImport(Kingfisher)
        if let url = CommonUtils.createUrlPath(hostURL, path: path) {
            showLoadingView()
            ImageDownloader.default.downloadImage(with: url,
                                                  options: []) { result in
                dismissLoadingView()
                switch result {
                case .success(let value):
                    completionHandler(value.image, value.originalData)
                    DebugLog("Task done for: \(url)")
                case .failure(let error):
                    completionHandler(nil, nil)
                    DebugLog("Job failed: \(error.localizedDescription)")
                }
            }
        } else {
            completionHandler(nil, nil)
        }
#else
        completionHandler(nil, nil)
#endif
    }

    static func downloadUrlImages(_ hostURL: String, paths: [String], isFileData: Bool = false, handler: @escaping ([UIImage]?, [Data]?) -> Void) {
        let syncQueue = DispatchQueue(label: "image.sync.queue")
        var images: [UIImage] = []
        var imageDatas: [Data] = []
#if canImport(Kingfisher)
        let waitGroup = DispatchGroup()
        showLoadingView()
        paths.forEach {
            if let url = CommonUtils.createUrlPath(hostURL, path: $0) {
                waitGroup.enter()

                ImageDownloader.default.downloadImage(with: url, options: []) { result in
                    var imageToAppend: UIImage?
                    var dataToAppend: Data?

                    switch result {
                    case .success(let value):
                        let mimeType = value.originalData.mimeType
                        if mimeType?.type == .webp,
                           let imageData = UIImage(data: value.originalData)?.jpegData(compressionQuality: 0.9),
                           let image = UIImage(data: imageData) {
                            imageToAppend = image
                            dataToAppend = imageData
                        } else {
                            imageToAppend = value.image
                            dataToAppend = value.originalData
                        }
                    case .failure(let error):
                        DebugLog("Job failed: \(error.localizedDescription)")
                    }

                    // 공유 배열에 접근은 이 안에서만
                    syncQueue.async {
                        if let image = imageToAppend, let data = dataToAppend {
                            images.append(image)
                            imageDatas.append(data)
                        }
                        waitGroup.leave()
                    }
                }
            }
        }

        waitGroup.notify(queue: .main) {
            dismissLoadingView()
            handler(images, imageDatas)
        }
#else
        handler(images, imageDatas)
#endif

    }

    static func downLocalImages(_ paths: [String], handler: @escaping ([UIImage]?, [Data]?) -> Void) {
        var images: [UIImage] = []
        var imageDatas: [Data] = []
#if canImport(Kingfisher)
        let waitGroup = DispatchGroup()
        showLoadingView()
        paths.forEach { atPath in
            if let url = URL(string: atPath) {
                waitGroup.enter()
                if let data = try? Data(contentsOf: url) {
                    let mimeType = data.mimeType
                    if mimeType?.type == .webp {
                            // webp는 지원하지 않아 jpg로 변경해서 저장한다... 저장시 에러남..ㅠㅠ
                        if let imageData = UIImage(data: data)?.jpegData(compressionQuality: 0.9),
                           let image = UIImage(data: imageData) {
                            images.append(image)
                            imageDatas.append(imageData)
                        }
                    } else {
                        if let image = UIImage(data: data) {
                            images.append(image)
                            imageDatas.append(data)
                        }
                    }
                    waitGroup.leave()
                }
            }
        }

        waitGroup.notify(queue: .main) {
            dismissLoadingView()
            handler(images, imageDatas)
        }
#else
        handler(images, imageDatas)
#endif
    }

    static func photoLibraryPermissionCheck(isReadFlag: Bool, callBack: @escaping (Bool, PHAuthorizationStatus?) -> Void) {
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: (isReadFlag ? .readWrite : .addOnly) ) { authorizationStatus in
                switch authorizationStatus {
                case .limited:
                    callBack(true, .limited)
                case .authorized:
                    callBack(true, .authorized)
                default:
                    callBack(false, authorizationStatus)
                }
            }
        } else {
            PHPhotoLibrary.requestAuthorization { status in
                 switch status {
                 case .authorized:
                    callBack(true, .authorized)
                 case .restricted:
                    callBack(false, .restricted)
                 case .denied:
                    callBack(false, .denied)
                 default:
                    // place for .notDetermined - in this callback status is already determined so should never get here
                    callBack(false, .denied)
                 }
            }
        }
    }

    static func audioRecordPermissionCheck(callBack: @escaping (Bool, AVAudioSession.RecordPermission?) -> Void) {

        switch AVAudioSession.sharedInstance().recordPermission {
        case .undetermined:
            // 아직 녹음 권한 요청이 되지 않음, 사용자에게 권한 요청
            AVAudioSession.sharedInstance().requestRecordPermission({ allowed in
                // completion(allowed)
                if allowed {
                    callBack(true, .granted)
                } else {
                    callBack(false, .denied)
                }
            })
        case .denied:
            // 사용자가 녹음 권한 거부, 사용자가 직접 설정 화면에서 권한 허용을 하게끔 유도
            callBack(false, .denied)
        case .granted:
            // 사용자가 녹음 권한 허용
            callBack(true, .granted)
        @unknown default:
            callBack(false, nil)
        }
    }

    // MARK: - 생체 인식
    static func canEvaluatePolicy(_ authPolicy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics) -> Bool {
        return LAContext().canEvaluatePolicy(authPolicy, error: nil)
    }

    static var getBiometryType: LABiometryType {
        return LAContext().biometryType
    }

    static func evaluatePolicy(_ policy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics,
                              reason: String = "본인 확인",
                              completion: @escaping (Bool) -> Void) {

        LAContext().evaluatePolicy(policy, localizedReason: reason) { (res, err) in
//            if let error = err {
//                DebugLog("evaluatePolicy Error: \(error ?? "") :: \(error.localizedDescription)")
//            }
            DispatchQueue.main.async {
                completion(res)
            }
        }
    }

    static func getImageBoxHeightSize(margin: CGFloat, boxWidth: CGFloat, boxHeight: CGFloat ) -> CGFloat {
        // 이미지 해상도 비율을 맞추기 위함
        // (original height / original width) x new width = new height
        let imageWidth = UIScreen.main.bounds.width - margin
        let newImageHeightSize: CGFloat = ((boxHeight / boxWidth) * imageWidth)
        return newImageHeightSize
    }

    static func userInfoToPushDic(_ userInfo: [AnyHashable : Any]) -> [String: Any] {
        let keys: [String] = userInfo.keys.compactMap({ "\($0)" })
        var remoteDic: [String: Any] = [:]

        keys.forEach { key in
            if key != "aps" {
                remoteDic[key] = userInfo[key]
            }
        }

        if let aps = userInfo["aps"] as? [String: Any] {
            aps.keys.forEach { key in
                if key != "alert" {
                    remoteDic[key] = aps[key]
                }
            }
        }

        return remoteDic
    }

    static func compressVideo(inputURL: URL, presetName: String, outputFileName: String? = nil, completion: @escaping (URL?, Error?) -> Void) {
        // 1. 먼저 비디오 파일이 유효한지 확인
        let asset = AVURLAsset(url: inputURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])

        // 2. 비디오 트랙 확인
        let videoTracks = asset.tracks(withMediaType: .video)
        guard !videoTracks.isEmpty else {
            DebugLog("비디오 트랙이 없습니다.")
            completion(nil, NSError(domain: "VideoCompression", code: -1, userInfo: [NSLocalizedDescriptionKey: "비디오 트랙이 없습니다."]))
            return
        }

        // 3. 비디오 정보 로깅
        if let videoTrack = videoTracks.first {
            let naturalSize = videoTrack.naturalSize
            let bitRate = videoTrack.estimatedDataRate
            DebugLog("원본 비디오 정보: 크기 \(naturalSize), 비트레이트 \(bitRate)")
        }

        // 4. 사용 가능한 프리셋 확인
        let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: asset)
        if !compatiblePresets.contains(presetName) {
            DebugLog("비디오 형식에 맞지 않는 프리셋: \(presetName)")
            // 대체 프리셋 사용 시도
            let alternatePreset = compatiblePresets.contains(AVAssetExportPreset640x480) ?
            AVAssetExportPreset640x480 : AVAssetExportPresetLowQuality
            DebugLog("대체 프리셋으로 시도: \(alternatePreset)")

            // 재귀적으로 다른 프리셋으로 시도
            compressVideo(inputURL: inputURL, presetName: alternatePreset, outputFileName: outputFileName, completion: completion)
            return
        }

        // 5. 고유한 출력 파일 이름 생성
        let originalFileName = inputURL.deletingPathExtension().lastPathComponent // ✅ 기존 파일명 유지
        var outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(originalFileName).mp4")
        if let outputFileName = outputFileName {
            outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(outputFileName).mp4")
        }

        // 6. 기존 파일이 있다면 제거
        if FileManager.default.fileExists(atPath: outputURL.path) {
            try? FileManager.default.removeItem(at: outputURL)
        }

        // 7. 내보내기 세션 설정
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: presetName) else {
            completion(nil, NSError(domain: "VideoCompression", code: -1, userInfo: [NSLocalizedDescriptionKey: "내보내기 세션을 생성할 수 없습니다."]))
            return
        }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true

        DispatchQueue.global(qos: .utility).async {
            exportSession.exportAsynchronously {
                DispatchQueue.main.async {
                    if exportSession.status == .completed {
                        DebugLog("비디오 압축 성공: \(outputURL.path)")
                        completion(outputURL, nil)
                    } else {
                        // 10. 상세한 오류 정보 확인
                        let errorDetails = exportSession.error?.localizedDescription ?? "Unknown error"
                        let errorCode = (exportSession.error as NSError?)?.code ?? -1
                        let errorDomain = (exportSession.error as NSError?)?.domain ?? "Unknown"

                        DebugLog("비디오 압축 실패: \(errorDetails), 코드: \(errorCode), 도메인: \(errorDomain)")
                        completion(nil, exportSession.error)
                    }
                }
            }
        }
    }
}
