// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import SystemConfiguration
import os.log
import UIKit
import CoreTelephony
import Photos
import LocalAuthentication

public enum DebugLogLevel: String {
    case debug, info, error, log, trace, notice, warning, critical, fault
}

public func DebugLog(_ message: Any? = "",
                     level: DebugLogLevel = .info,
                     file: String = #file,
                     funcName: String = #function,
                     line: Int = #line,
                     param: [String: Any] = [:]) {
// #if DEBUG
    let fileName: String = (file as NSString).lastPathComponent
    let fullMessage = """
    [\(fileName)] [\(funcName)] [\(line)]
    \(message ?? "")
    """
    if #available(iOS 14.0, *) {
        // Xcode15 로깅 기능 추가. https://ios-development.tistory.com/381
        let logger = Logger(subsystem: CommonUtils.getBundleIdentifier, category: level.rawValue)
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
// #endif
}

public class CommonUtils {
    static public func getAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }

    static public var getAppName: String {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Medisay"
    }

    static public var getBundleIdentifier: String {
        return Bundle.main.bundleIdentifier ?? (Bundle.main.infoDictionary?["BundleIdentifier"] as? String ?? "")
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

public extension CommonUtils {
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
//                DLog("evaluatePolicy Error: \(error ?? "") :: \(error.localizedDescription)")
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
}
