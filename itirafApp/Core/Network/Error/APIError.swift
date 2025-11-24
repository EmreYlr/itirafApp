//
//  APIError.swift
//  itirafApp
//
//  Created by Emre on 8.10.2025.
//

//TODO: - App deki tüm hataları yap
struct APIError: Decodable, Error {
    let code: Int
    let type: String
}
