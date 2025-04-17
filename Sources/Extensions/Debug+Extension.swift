//
//  Debug+Extension.swift
//
//
// Created by Dongju Lim on 8/12/24.
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
        guard JSONSerialization.isValidJSONObject(self) else { return "" }
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
