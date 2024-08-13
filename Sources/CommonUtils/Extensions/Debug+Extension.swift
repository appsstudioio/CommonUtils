//
//  Debug+Extension.swift
//
//
//  Created by 10-N3344 on 8/12/24.
//

import Foundation

public extension Data {
    var prettyString: NSString? {
        return NSString(data: self, encoding: String.Encoding.utf8.rawValue) ?? nil
    }

    var toPrettyString: String {
        do {
            let json = try JSONSerialization.jsonObject(with: self, options: [])
            let data = try JSONSerialization.data(withJSONObject: json, options: [.sortedKeys, .prettyPrinted])
            guard let jsonString = String(data: data, encoding: .utf8) else {
                return ""
            }
            return jsonString
        } catch {
            DebugLog("Error: \(error.localizedDescription)")
            return ""
        }
    }
}

public extension Dictionary {
    var debugPrettyString: String {
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: [.sortedKeys, .prettyPrinted])
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            return ""
        }
    }

    func dump() {
        DebugLog(self as NSDictionary)
    }
}

public extension Encodable {
    var debugPrettyString: String {
        do {
            let encode = JSONEncoder()
            encode.outputFormatting = [.sortedKeys, .prettyPrinted]
            let jsonData = try encode.encode(self)
            return String(data: jsonData, encoding: .utf8) ?? ""
        } catch {
            return ""
        }
    }
}

public extension String {
    func debugLog(showTime: Bool = true, file: String = #file, funcName: String = #function, line: Int = #line) {
#if RELEASE
#else
        let fileName: String = (file as NSString).lastPathComponent
        var fullMessage = "[\(fileName)] [\(funcName) (\(line))]\n-> \(self)\n"

        if true == showTime {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale.current
            dateFormatter.dateFormat = "MM.dd KK:mm:ss.SSS"
            let timeStr = dateFormatter.string(from: Date())
            fullMessage = "\(timeStr): " + fullMessage
        }
        fullMessage += "\n"

        print(fullMessage)
#endif
    }
}
