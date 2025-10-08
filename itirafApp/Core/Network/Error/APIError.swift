//
//  APIError.swift
//  itirafApp
//
//  Created by Emre on 8.10.2025.
//

struct APIError: Decodable, Error {
    let code: Int
    let type: String
    let message: String
}
