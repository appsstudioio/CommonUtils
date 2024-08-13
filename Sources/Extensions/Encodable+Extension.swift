//
//  Encodable+Extension.swift
//  Medisay
//
//  Created by 10-N3344 on 2023/06/14.
//

import Foundation

public extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }

    var toDictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self),
              let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return dictionary
    }

    func asString() throws -> String? {
        let data = try JSONEncoder().encode(self)
        return String(data: data, encoding: .utf8)
    }
}
