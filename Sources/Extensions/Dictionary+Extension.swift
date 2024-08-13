//
//  Dictionary+Extension.swift
//
//
//  Created by 10-N3344 on 2023/06/14.
//

import Foundation

public extension Dictionary {
    var toData: Data? {
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: [])
            return data
        } catch {
            return nil
        }
    }

    func toString(divide: String = ", ") -> String {
        let str = (self.compactMap({ (key, value) -> String in
            return "\(key)=\(value)"
        }) as Array).joined(separator: divide)
        return str
    }

    func filterReturnString(key: String) -> String? {
        let value = self.filter {($0.key as? String == key)}.first?.value

        if value is String {
            guard let stringValue = value as? String else { return nil }
            return stringValue
        } else if value is Int {
            guard let intValue = value as? Int else { return nil }
            return "\(intValue)"
        } else if value is Double {
            guard let doubleValue = value as? Double else { return nil }
            return "\(doubleValue)"
        }

        return nil
    }

    var toJsonString: String {
        if let data = try? JSONSerialization.data(withJSONObject: self) {
            return String(data: data, encoding: .utf8) ?? ""
        }
        return ""
    }

    func toDecodableObject<T: Codable>(model: T.Type) -> Codable? {
        guard let data = self.toData else { return nil }
        do {
            return try JSONDecoder().decode(model.self, from: data)
        } catch DecodingError.keyNotFound(let key, let context){
            DebugLog("toDecodableObject Decode Error :: could not find key \(key) in JSON: \(context.debugDescription)", level: .error)
        } catch DecodingError.valueNotFound(let key, let context){
            DebugLog("toDecodableObject Decode Error :: could not find key \(key) in JSON: \(context.debugDescription)", level: .error)
        } catch DecodingError.typeMismatch(let type, let context) {
            DebugLog("toDecodableObject Decode Error :: type mismatch for type \(type) in JSON: \(context.debugDescription)", level: .error)
        } catch DecodingError.dataCorrupted(let context) {
            DebugLog("toDecodableObject Decode Error :: data found to be corrupted in JSON: \(context.debugDescription)", level: .error)
        } catch let jsonError {
            DebugLog("toDecodableObject :: \(jsonError.localizedDescription)", level: .error)
        }
        return nil
    }

}
