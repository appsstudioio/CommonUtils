//
//  ActivityShareItemPreparer.swift
//  CommonUtils
//

import Foundation

enum ActivityShareEnvironment {
    static var shouldMaterializeData: Bool {
        #if os(iOS) && !targetEnvironment(macCatalyst) && !targetEnvironment(simulator)
        if #available(iOS 14.0, *) {
            return ProcessInfo.processInfo.isiOSAppOnMac
        }
        #endif

        return false
    }
}

final class ActivityShareItemPreparer {
    typealias DataWriter = (Data, URL) throws -> Void

    let activityItems: [Any]

    var temporaryDirectoryURL: URL? {
        cleanupLock.lock()
        defer { cleanupLock.unlock() }
        return storedTemporaryDirectoryURL
    }

    private let fileManager: FileManager
    private let cleanupLock = NSLock()
    private var storedTemporaryDirectoryURL: URL?

    private init(
        activityItems: [Any],
        temporaryDirectoryURL: URL?,
        fileManager: FileManager
    ) {
        self.activityItems = activityItems
        self.storedTemporaryDirectoryURL = temporaryDirectoryURL
        self.fileManager = fileManager
    }

    deinit {
        cleanup()
    }

    static func requiresPreparation(
        activityItems: [Any],
        shouldMaterializeData: Bool
    ) -> Bool {
        guard shouldMaterializeData else { return false }

        return activityItems.contains { item in
            guard let data = data(from: item) else { return false }
            return !data.isEmpty
        }
    }

    /// 판별 가능한 Data를 공유 세션 전용 임시 파일로 변환합니다.
    static func prepare(
        activityItems: [Any],
        shouldMaterializeData: Bool,
        fileManager: FileManager = .default,
        temporaryDirectory: URL? = nil,
        dataWriter: DataWriter? = nil
    ) -> ActivityShareItemPreparer {
        guard shouldMaterializeData else {
            return ActivityShareItemPreparer(
                activityItems: activityItems,
                temporaryDirectoryURL: nil,
                fileManager: fileManager
            )
        }

        let rootDirectory = temporaryDirectory ?? fileManager.temporaryDirectory
        let writer = dataWriter ?? { data, fileURL in
            try data.write(to: fileURL, options: .atomic)
        }
        var sessionDirectoryURL: URL?
        var preparedItems = [Any]()
        preparedItems.reserveCapacity(activityItems.count)

        for (index, item) in activityItems.enumerated() {
            guard let data = data(from: item),
                  !data.isEmpty,
                  let mimeType = data.mimeType,
                  isSafeToMaterialize(mimeType.type) else {
                preparedItems.append(item)
                continue
            }

            do {
                let directoryURL: URL
                if let sessionDirectoryURL {
                    directoryURL = sessionDirectoryURL
                } else {
                    directoryURL = try createSessionDirectory(
                        in: rootDirectory,
                        fileManager: fileManager
                    )
                    sessionDirectoryURL = directoryURL
                }

                let fileURL = directoryURL
                    .appendingPathComponent("share-\(index + 1)")
                    .appendingPathExtension(mimeType.ext)
                try writer(data, fileURL)
                preparedItems.append(fileURL)
            } catch {
                DebugLog(
                    "공유 항목 임시 파일 변환 실패",
                    level: .error,
                    param: [
                        "index": index,
                        "mimeType": mimeType.mime,
                        "fileExtension": mimeType.ext,
                        "error": error.localizedDescription
                    ],
                    isDebugPrint: true,
                    isFileLog: false
                )
                preparedItems.append(item)
            }
        }

        return ActivityShareItemPreparer(
            activityItems: preparedItems,
            temporaryDirectoryURL: sessionDirectoryURL,
            fileManager: fileManager
        )
    }

    /// 공유 세션에서 만든 임시 디렉터리만 정리합니다.
    func cleanup() {
        cleanupLock.lock()
        let directoryURL = storedTemporaryDirectoryURL
        storedTemporaryDirectoryURL = nil
        cleanupLock.unlock()

        guard let directoryURL else { return }

        do {
            try fileManager.removeItem(at: directoryURL)
        } catch CocoaError.fileNoSuchFile {
            return
        } catch {
            DebugLog(
                "공유 임시 디렉터리 정리 실패",
                level: .error,
                param: ["error": error.localizedDescription],
                isDebugPrint: true,
                isFileLog: false
            )
        }
    }
}

private extension ActivityShareItemPreparer {
    static func data(from item: Any) -> Data? {
        if let data = item as? Data {
            return data
        }
        if let data = item as? NSData {
            return data as Data
        }
        return nil
    }

    static func createSessionDirectory(
        in temporaryDirectory: URL,
        fileManager: FileManager
    ) throws -> URL {
        let directoryURL = temporaryDirectory
            .appendingPathComponent("CommonUtilsShare", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)

        try fileManager.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )
        return directoryURL
    }

    static func isSafeToMaterialize(_ fileType: FileType) -> Bool {
        switch fileType {
        case .jpg, .png, .gif, .heic, .heif, .webp, .bmp, .tif,
                .pdf, .rtf,
                .mp3, .aac, .wav, .m4a,
                .mp4, .mov, .m4v:
            return true
        default:
            return false
        }
    }
}
