//
//  Encodable+Extension.swift
//  itirafApp
//
//  Created by Emre on 19.11.2025.
//

import Foundation

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError(domain: "EncodingError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Dictionary conversion failed"])
        }
        return dictionary
    }
}
