//
//  APIError.swift
//  itirafApp
//
//  Created by Emre on 8.10.2025.
//

struct APIError: Decodable, Error {
    let code: Int
    let type: String
    
    var customMessage: String?
    var customTitle: String?
    
    private enum CodingKeys: String, CodingKey {
        case code
        case type
    }
}
