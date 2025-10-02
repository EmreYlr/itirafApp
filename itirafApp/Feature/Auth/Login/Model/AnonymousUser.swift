//
//  AnonymousUser.swift
//  itirafApp
//
//  Created by Emre on 1.10.2025.
//

struct User: Codable {
    var id: Int?
    var username: String?
    var email: String
    var isAnonymous: Bool?
}
