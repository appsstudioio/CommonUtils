// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import SystemConfiguration
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

    static public func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
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

    static public func getVideoThumbnailImage(fileUrl: URL) -> UIImage? {
        // 썸네일 사진
        do {
            let videoAsset = AVAsset(url: fileUrl)
            let assetImgGenerate = AVAssetImageGenerator(asset: videoAsset)
            assetImgGenerate.appliesPreferredTrackTransform = true

            let time = CMTimeMakeWithSeconds(0.0, preferredTimescale: 600)
            let cgImg = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let img = UIImage(cgImage: cgImg)
            return img
        } catch let error {
            DebugLog(error.localizedDescription)
            return nil
        }
    }

    static public func extractVideoInfo(from url: URL) -> CommonUtilVideoInfo {
        let asset = AVAsset(url: url)
        let duration = CMTimeGetSeconds(asset.duration)
        var resolution: CGSize? = nil
        var frameRate: Float? = nil
        var bitRate: Float? = nil
        var videoCodec: String? = nil
        var audioCodec: String? = nil
        var audioSampleRate: Float64? = nil
        var audioChannels: Int? = nil

        if let videoTrack = asset.tracks(withMediaType: .video).first {
            let size = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
            resolution = CGSize(width: abs(size.width), height: abs(size.height))
            frameRate = videoTrack.nominalFrameRate
            bitRate = videoTrack.estimatedDataRate // bps

            // 코덱 정보
            if let formatDescription = videoTrack.formatDescriptions.first {
                let desc = formatDescription as! CMFormatDescription
                let codecType = CMFormatDescriptionGetMediaSubType(desc)
                videoCodec = codecType.toString()
            }
        }

        if let audioTrack = asset.tracks(withMediaType: .audio).first {
            let formatDescription = audioTrack.formatDescriptions.first as! CMAudioFormatDescription
            if let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription)?.pointee {
                audioCodec = audioTrack.mediaType.rawValue
                audioSampleRate = asbd.mSampleRate
                audioChannels = Int(asbd.mChannelsPerFrame)
            }
        }

        return CommonUtilVideoInfo(
            duration: duration,
            resolution: resolution,
            frameRate: frameRate,
            bitRate: bitRate,
            videoCodec: videoCodec,
            audioCodec: audioCodec,
            audioSampleRate: audioSampleRate,
            audioChannels: audioChannels
        )
    }

    // 동영상 압축 함수
    static public func compressVideo(inputURL: URL,
                                     outputURL: URL,
                                     quality: CommonUtilCompressionQuality = .medium,
                                     maxFileSize: Int64? = nil, // 최대 파일 크기 제한 (옵셔널)
                                     completion: @escaping (Result<URL, Error>) -> Void) {

        // 입력 동영상의 애셋 생성
        let asset = AVAsset(url: inputURL)

        // 비디오 트랙 가져오기
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            completion(.failure(CommonUtilCompressionError.exportSessionFailure("비디오 트랙을 찾을 수 없음")))
            return
        }

        // 기존 비디오 정보 가져오기
        let originalVideoInfo = self.extractVideoInfo(from: inputURL)
        let originalSize = videoTrack.naturalSize
        let duration = originalVideoInfo.duration

        // 원본 파일 크기 확인
        let originalFileSize = self.getFileSize(filePath: inputURL.path).int64Value

        // 원본 비트레이트 계산 (bps)
        let originalBitRate: Float = (originalVideoInfo.bitRate ?? Float(Double((originalFileSize)) * 8 / duration))
        // 품질 설정에 따른 목표 비트레이트 계산 (원본 기준)
        var targetBitRate: Float = originalBitRate * quality.compressionRatio
        // 최소 비트레이트는 원본 비트레이트를 초과하지 않도록 함
        let safeMinimumBitRate: Float = min(quality.minimumBitRate, originalBitRate)
        // 계산된 목표 비트레이트와 안전한 최소 비트레이트 중 큰 값 선택
        targetBitRate = max(targetBitRate, safeMinimumBitRate)
        // 추가 안전장치: 어떤 경우에도 원본 비트레이트보다 커지지 않도록 함
        targetBitRate = min(targetBitRate, originalBitRate)

        // 오디오 비트레이트 (비디오는 전체 비트레이트의 약 90%로 가정)
        let videoBitRate = targetBitRate * 0.9
        let audioSampleRate = originalVideoInfo.audioSampleRate ?? 44100
        let audioChannels = originalVideoInfo.audioChannels ?? 2
        let audioBitRate: Float = 128_000 // 128 kbps (표준 오디오 품질)
        let estimatedFileSize = Int64((videoBitRate + audioBitRate) * Float(duration) / 8) // 예상 파일 사이즈
        DebugLog("원본 비디오 정보: \(originalVideoInfo)")
        DebugLog("원본 비트레이트: \(originalBitRate / 1_000_000) Mbps")
        DebugLog("목표 비트레이트: \(targetBitRate / 1_000_000) Mbps")
        DebugLog("비디오 비트레이트: \(videoBitRate / 1_000_000) Mbps")
        DebugLog("원본 파일 사이즈: \(originalFileSize.toFileByteSting)")
        DebugLog("예상 파일 사이즈: \(estimatedFileSize.toFileByteSting)")

        // 최대 파일 크기 제한이 있는 경우, 예상 파일 크기 미리 계산
        if let maxFileSize = maxFileSize {
            if estimatedFileSize > maxFileSize {
                // maxFileSize를 초과할 경우 에러 반환
                completion(.failure(CommonUtilCompressionError.minimumQualityExceedsMaxFileSize(estimatedFileSize)))
                return
            }
        }

        // 압축 세션 설정
        do {
            // 컴포지션 생성
            let composition = AVMutableComposition()

            // 비디오 트랙 추가
            guard let compositionVideoTrack = composition.addMutableTrack(
                withMediaType: .video,
                preferredTrackID: kCMPersistentTrackID_Invalid) else {
                completion(.failure(CommonUtilCompressionError.exportSessionFailure("Composition 비디오 트랙 생성 실패")))
                return
            }

            // 원본 비디오 트랙 삽입
            try compositionVideoTrack.insertTimeRange(
                CMTimeRange(start: .zero, duration: asset.duration),
                of: videoTrack,
                at: .zero
            )
            compositionVideoTrack.preferredTransform = videoTrack.preferredTransform

            // 오디오 트랙이 있으면 추가
            var audioTrackExists = false
            if let audioTrack = asset.tracks(withMediaType: .audio).first {
                audioTrackExists = true
                guard let compositionAudioTrack = composition.addMutableTrack(
                    withMediaType: .audio,
                    preferredTrackID: kCMPersistentTrackID_Invalid) else {
                    completion(.failure(CommonUtilCompressionError.exportSessionFailure("Composition 오디오 트랙 생성 실패")))
                    return
                }

                try compositionAudioTrack.insertTimeRange(
                    CMTimeRange(start: .zero, duration: asset.duration),
                    of: audioTrack,
                    at: .zero
                )
            }

            // 이미 파일이 존재한다면 삭제
            if FileManager.default.fileExists(atPath: outputURL.path) {
                try FileManager.default.removeItem(at: outputURL)
            }

            // AVAssetWriter 설정
            let assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)

            // 비디오 설정
            let videoSettings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: originalSize.width,
                AVVideoHeightKey: originalSize.height,
                AVVideoCompressionPropertiesKey: [
                    AVVideoAverageBitRateKey: videoBitRate,
                    AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
                    AVVideoMaxKeyFrameIntervalKey: 60, // 키프레임 간격 늘리기
                    AVVideoExpectedSourceFrameRateKey: Int(originalVideoInfo.frameRate ?? 30) // 원본 프레임레이트 사용
                ]
            ]

            // 비디오 입력 설정
            let videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
            videoWriterInput.expectsMediaDataInRealTime = false
            videoWriterInput.transform = videoTrack.preferredTransform

            if assetWriter.canAdd(videoWriterInput) {
                assetWriter.add(videoWriterInput)
            } else {
                completion(.failure(CommonUtilCompressionError.exportSessionFailure("비디오 입력을 추가할 수 없음")))
                return
            }

            // 오디오 설정 및 입력 추가 (오디오 트랙이 있는 경우)
            var audioWriterInput: AVAssetWriterInput?
            if audioTrackExists {
                let audioSettings: [String: Any] = [
                    AVFormatIDKey: kAudioFormatMPEG4AAC,
                    AVNumberOfChannelsKey: audioChannels,
                    AVSampleRateKey: audioSampleRate,
                    AVEncoderBitRateKey: audioBitRate
                ]

                audioWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
                audioWriterInput?.expectsMediaDataInRealTime = false

                if let audioInput = audioWriterInput, assetWriter.canAdd(audioInput) {
                    assetWriter.add(audioInput)
                }
            }

            // 에셋 리더 설정
            let assetReader = try AVAssetReader(asset: composition)

            // 비디오 출력 설정
            let videoReaderOutput = AVAssetReaderTrackOutput(
                track: compositionVideoTrack,
                outputSettings: [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange]
            )

            if assetReader.canAdd(videoReaderOutput) {
                assetReader.add(videoReaderOutput)
            } else {
                completion(.failure(CommonUtilCompressionError.exportSessionFailure("비디오 출력을 추가할 수 없음")))
                return
            }

            // 오디오 출력 설정 (오디오 트랙이 있는 경우)
            var audioReaderOutput: AVAssetReaderTrackOutput?
            if audioTrackExists, let audioTrack = composition.tracks(withMediaType: .audio).first {
                audioReaderOutput = AVAssetReaderTrackOutput(
                    track: audioTrack,
                    outputSettings: [AVFormatIDKey: kAudioFormatLinearPCM]
                )

                if let audioOutput = audioReaderOutput, assetReader.canAdd(audioOutput) {
                    assetReader.add(audioOutput)
                }
            }

            // 처리 시작
            assetReader.startReading()
            assetWriter.startWriting()
            assetWriter.startSession(atSourceTime: .zero)

            // 디스패치 그룹 생성
            let processingGroup = DispatchGroup()

            // 비디오 처리
            processingGroup.enter()
            videoWriterInput.requestMediaDataWhenReady(on: DispatchQueue(label: "videoCompression.queue")) {
                while videoWriterInput.isReadyForMoreMediaData {
                    if let sampleBuffer = videoReaderOutput.copyNextSampleBuffer() {
                        videoWriterInput.append(sampleBuffer)
                    } else {
                        videoWriterInput.markAsFinished()
                        processingGroup.leave()
                        break
                    }
                }
            }

            // 오디오 처리 (오디오 트랙이 있는 경우)
            if let audioWriterInput = audioWriterInput, let audioReaderOutput = audioReaderOutput {
                processingGroup.enter()
                audioWriterInput.requestMediaDataWhenReady(on: DispatchQueue(label: "audioCompression.queue")) {
                    while audioWriterInput.isReadyForMoreMediaData {
                        if let sampleBuffer = audioReaderOutput.copyNextSampleBuffer() {
                            audioWriterInput.append(sampleBuffer)
                        } else {
                            audioWriterInput.markAsFinished()
                            processingGroup.leave()
                            break
                        }
                    }
                }
            }

            // 모든 처리가 완료되면 압축 완료
            processingGroup.notify(queue: DispatchQueue.main) {
                if assetReader.status == .completed {
                    assetWriter.finishWriting {
                        if assetWriter.status == .completed {
                            // 압축 결과 파일 크기 확인
                            let compressedSize = self.getFileSize(filePath: outputURL.path).int64Value
                            let compressionRatio = Double(compressedSize) / Double(originalFileSize) * 100

                            DebugLog("원본 파일 크기: \(originalFileSize / 1024 / 1024) MB")
                            DebugLog("압축 파일 크기: \(compressedSize / 1024 / 1024) MB")
                            DebugLog("압축률: \(compressionRatio)%")

                            completion(.success(outputURL))
                        } else {
                            let error = assetWriter.error ?? CommonUtilCompressionError.unknownError
                            completion(.failure(error))
                        }
                    }
                } else {
                    let error = assetReader.error ?? CommonUtilCompressionError.unknownError
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    static public func renamedTempFileURL(originalFileURL: URL, renamedFileName: String) -> URL? {
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory

        let fileExtension = originalFileURL.pathExtension
        let renamedFileURL = tempDirectory.appendingPathComponent("\(renamedFileName).\(fileExtension)")

        do {
            if fileManager.fileExists(atPath: renamedFileURL.path) {
                try fileManager.removeItem(at: renamedFileURL)
            }
            try fileManager.copyItem(at: originalFileURL, to: renamedFileURL)
            return renamedFileURL
        } catch {
            DebugLog("파일 이름 변경 실패: \(error.localizedDescription)")
            return nil
        }
    }

    /// HTML 문자열의 유효성을 확인하고, 정제된 문자열을 반환
    static public func validateHTML(html: String) -> Bool {
        let trimmedHTML = html.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedHTML.isEmpty else {
            DebugLog("HTML 문자열이 비어 있음", level: .error)
            return false
        }

        // UTF-8 인코딩 가능 여부
        guard trimmedHTML.data(using: .utf8) != nil else {
            DebugLog("UTF-8 인코딩 실패", level: .error, param: ["html": html])
            return false
        }

        // 정제
        var sanitizedHTML = trimmedHTML.lowercased()
        sanitizedHTML = sanitizedHTML.replacingOccurrences(of: "<script[^>]*>.*?</script>", with: "", options: .regularExpression)
        sanitizedHTML = sanitizedHTML.replacingOccurrences(of: "<style[^>]*>.*?</style>", with: "", options: .regularExpression)
        sanitizedHTML = sanitizedHTML.replacingOccurrences(of: "<meta[^>]*>", with: "", options: .regularExpression)

        // 필수 태그 순서 확인
        guard
            let htmlIndex = sanitizedHTML.range(of: "<html")?.lowerBound,
            let headIndex = sanitizedHTML.range(of: "<head")?.lowerBound,
            let bodyIndex = sanitizedHTML.range(of: "<body")?.lowerBound
        else {
            DebugLog("필수 태그 누락 -> [\(html)]", level: .error)
            return false
        }

        let indices = [htmlIndex, headIndex, bodyIndex]
        let isOrdered = indices == indices.sorted(by: { $0 < $1 })
        guard isOrdered else {
            DebugLog("태그 순서가 잘못됨 -> [\(html)]", level: .error)
            return false
        }

        return true
    }
}

private extension FourCharCode {
    func toString() -> String? {
        let n = self
        let c1 = Character(UnicodeScalar((n >> 24) & 255)!)
        let c2 = Character(UnicodeScalar((n >> 16) & 255)!)
        let c3 = Character(UnicodeScalar((n >> 8) & 255)!)
        let c4 = Character(UnicodeScalar(n & 255)!)
        return "\(c1)\(c2)\(c3)\(c4)"
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
            guard let url = CommonUtils.createUrlPath(hostURL, path: $0) else { return }
            waitGroup.enter()

            ImageDownloader.default.downloadImage(with: url, options: []) { result in
                // 공유 배열에 접근은 이 안에서만
                syncQueue.async {
                    defer {
                        waitGroup.leave()
                    }
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

                    if let image = imageToAppend, let data = dataToAppend {
                        images.append(image)
                        imageDatas.append(data)
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

public extension CommonUtils {
    // MARK: - Memory Info
    private static func getMemoryInfo() -> (freeMB: UInt64, totalMB: UInt64) {
        let total = ProcessInfo.processInfo.physicalMemory / 1024 / 1024

        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout.size(ofValue: stats) / MemoryLayout<integer_t>.size)
        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        var free: UInt64 = 0
        if result == KERN_SUCCESS {
            let pageSize = UInt64(vm_kernel_page_size)
            free = (UInt64(stats.free_count) + UInt64(stats.inactive_count)) * pageSize / 1024 / 1024
        }

        return (freeMB: free, totalMB: total)
    }

    // MARK: - Disk Space Info
    private static func getDiskSpaceInfo() -> (freeGB: String, totalGB: String) {
        if let attributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
           let total = attributes[.systemSize] as? NSNumber,
           let free = attributes[.systemFreeSize] as? NSNumber {

            let byteToGB: (NSNumber) -> String = { bytes in
                String(format: "%.2f", Double(truncating: bytes) / 1_073_741_824)
            }
            return (freeGB: byteToGB(free), totalGB: byteToGB(total))
        }
        return ("N/A", "N/A")
    }

    static func collectInfoForSupport() -> String {
        let appVersion = self.getAppVersion()
        let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "N/A"
        let systemVersion = self.getSystemVersion()
        let deviceModel = self.getDeviceModel()
        let memoryInfo = self.getMemoryInfo()
        let diskSpace = self.getDiskSpaceInfo()
        let language = Locale.preferredLanguages.first ?? "N/A"
        let region = Locale.current.regionCode ?? "N/A"
        return """
        --- 시스템 정보 ---
        • 앱 버전: \(appVersion) (\(appBuild))
        • iOS 버전: \(systemVersion)
        • 기기: \(deviceModel)
        • 여유 메모리: \(memoryInfo.freeMB) MB / 총 \(memoryInfo.totalMB) MB
        • 디스크 여유 공간: \(diskSpace.freeGB) GB / 총 \(diskSpace.totalGB) GB
        • 언어 설정: \(language)
        • 지역 설정: \(region)
        """
    }
}
