//
// DebugLoggerManager.swift
// CommonUtils
//
// Created by Dongju Lim on 6/19/25
//

import Foundation
import ZIPFoundation
import SystemConfiguration
import os.log

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
                     param: [String: Any] = [:],
                     isDebugPrint: Bool = false) {
    if isDebugPrint {
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
    }

    switch level {
    case .debug,
            .error,
            .log,
            .trace,
            .critical,
            .fault
        :
        DebugLoggerManager.shared.log(message, level: level, file: file, funcName: funcName, line: line, param: param)
    default: break
    }
}

public final class DebugLoggerManager {

    public static let shared = DebugLoggerManager()

    private let logDirectory: URL
    private let logQueue = DispatchQueue(label: "\(CommonUtils.getBundleIdentifier).debuglogger", qos: .utility)
    private let maxFileSize: UInt64 = 512 * 1024 // 512KB
    private let maxTotalLogDirectorySize: UInt64 = 50 * 1024 * 1024 // 50MB
    private var lastCleanupTime: Date = .distantPast
    private let cleanupInterval: TimeInterval = 60 * 10 // 10분

    private init() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.logDirectory = documents.appendingPathComponent("Logs", isDirectory: true)
        createDirectoryIfNeeded()
        removeOldLogsIfNeeded(force: true)
    }

    private func createDirectoryIfNeeded() {
        if !FileManager.default.fileExists(atPath: self.logDirectory.path) {
            try? FileManager.default.createDirectory(at: self.logDirectory, withIntermediateDirectories: true)
        }
    }

    private func removeOldLogsIfNeeded(force: Bool = false) {
        let now = Date()
        guard force || now.timeIntervalSince(lastCleanupTime) > cleanupInterval else { return }

        lastCleanupTime = now

        let fileManager = FileManager.default
        let expirationDate = Calendar.current.date(byAdding: .day, value: -30, to: now)!
        guard let files = try? fileManager.contentsOfDirectory(at: self.logDirectory, includingPropertiesForKeys: [.creationDateKey]) else { return }

        // 1. 삭제 대상: 30일 초과된 파일
        for file in files {
            if let creationDate = try? file.resourceValues(forKeys: [.creationDateKey]).creationDate,
               creationDate < expirationDate {
                try? fileManager.removeItem(at: file)
            }
        }

        // 2. 디렉토리 전체 용량 검사
        var remainingFiles = getAllLogFiles().sorted { lhs, rhs in
            let lhsDate = (try? lhs.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? .distantPast
            let rhsDate = (try? rhs.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? .distantPast
            return lhsDate < rhsDate
        }

        while totalLogDirectorySize() > maxTotalLogDirectorySize, let oldest = remainingFiles.first {
            try? fileManager.removeItem(at: oldest)
            remainingFiles.removeFirst()
        }
    }

    private func totalLogDirectorySize() -> UInt64 {
        let files = getAllLogFiles()
        return files.reduce(0) { total, file in
            let size = (try? FileManager.default.attributesOfItem(atPath: file.path)[.size]) as? UInt64 ?? 0
            return total + size
        }
    }

    private func getLogFileURL() -> URL {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let datePrefix = formatter.string(from: Date())

        let fileManager = FileManager.default

        for index in 1...100 {
            let fileName = "\(datePrefix)_\(String(format: "%02d", index)).log"
            let fileURL = logDirectory.appendingPathComponent(fileName)

            if !fileManager.fileExists(atPath: fileURL.path) {
                return fileURL
            }

            if let fileSize = try? fileManager.attributesOfItem(atPath: fileURL.path)[.size] as? UInt64,
               fileSize < maxFileSize {
                return fileURL
            }
        }

        return logDirectory.appendingPathComponent("\(datePrefix)_100.log")
    }

    public func log(_ message: Any?,
             level: DebugLogLevel,
             file: String,
             funcName: String,
             line: Int,
             param: [String: Any]) {

        logQueue.async {
            self.removeOldLogsIfNeeded()

            let date = Date()
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm:ss"

            let logEntry = """
            [\(timeFormatter.string(from: date))] [\(level.rawValue)] \(message ?? "")
            ↪︎ File: \((file as NSString).lastPathComponent)
            ↪︎ Func: \(funcName), Line: \(line)
            ↪︎ Params: \(param.map { "\($0): \($1)" }.joined(separator: ", "))
            
            """

            let logFileURL = self.getLogFileURL()

            if let data = logEntry.data(using: .utf8) {
                if FileManager.default.fileExists(atPath: logFileURL.path) {
                    if let fileHandle = try? FileHandle(forWritingTo: logFileURL) {
                        defer { fileHandle.closeFile() }
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(data)
                    }
                } else {
                    try? data.write(to: logFileURL)
                }
            }
        }
    }

    func getAllLogFiles() -> [URL] {
        (try? FileManager.default.contentsOfDirectory(at: logDirectory, includingPropertiesForKeys: nil)) ?? []
    }

    public func zipLogFiles() -> URL? {
        let fileManager = FileManager.default
        let zipFileURL = logDirectory.appendingPathComponent("logs.zip")

        try? fileManager.removeItem(at: zipFileURL)

        let logFiles = getAllLogFiles()
        guard !logFiles.isEmpty else { return nil }

        guard let archive = Archive(url: zipFileURL, accessMode: .create) else { return nil }

        for file in logFiles {
            try? archive.addEntry(with: file.lastPathComponent, relativeTo: logDirectory)
        }

        return zipFileURL
    }
}
