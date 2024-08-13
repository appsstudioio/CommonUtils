//
//  Array+Extension.swift
//
//
//  Created by 10-N3344 on 8/12/24.
//

import Foundation

// https://lygon55555.medium.com/%EC%8A%A4%EC%9C%84%ED%94%84%ED%8A%B8%EC%97%90%EC%84%9C-%EB%B0%B0%EC%97%B4%EC%9D%98-%EC%A4%91%EB%B3%B5%EB%90%98%EB%8A%94-%EC%9B%90%EC%86%8C-%EC%A0%9C%EA%B1%B0%ED%95%98%EB%8A%94-%EB%B0%A9%EB%B2%95-d3518f59486b
public extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}

public extension Array {
    var toData: Data? {
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: [])
            return data
        } catch {
            return nil
        }
    }

    var toJsonString: String {
        if let data = try? JSONSerialization.data(withJSONObject: self) {
            return String(data: data, encoding: .utf8) ?? ""
        }
        return ""
    }

    func unique<T:Hashable>(map: ((Element) -> (T)))  -> [Element] {
        var set = Set<T>() //the unique list kept in a Set for fast retrieval
        var arrayOrdered = [Element]() //keeping the unique list of elements but ordered
        for value in self {
            if !set.contains(map(value)) {
                set.insert(map(value))
                arrayOrdered.append(value)
            }
        }

        return arrayOrdered
    }

    func toDecodableObject<T: Codable>(model: T.Type) -> Codable? {
        guard let data = self.toData else { return nil }
        do {
            return try JSONDecoder().decode(model.self, from: data)
        } catch DecodingError.keyNotFound(let key, let context){
            DebugLog("toDecodableObject Decode Error :: could not find key \(key) in JSON: \(context.debugDescription)")
        } catch DecodingError.valueNotFound(let key, let context){
            DebugLog("toDecodableObject Decode Error :: could not find key \(key) in JSON: \(context.debugDescription)")
        } catch DecodingError.typeMismatch(let type, let context) {
            DebugLog("toDecodableObject Decode Error :: type mismatch for type \(type) in JSON: \(context.debugDescription)")
        } catch DecodingError.dataCorrupted(let context) {
            DebugLog("toDecodableObject Decode Error :: data found to be corrupted in JSON: \(context.debugDescription)")
        } catch let jsonError {
            DebugLog("toDecodableObject :: \(jsonError.localizedDescription)")
        }
        return nil
    }
}

