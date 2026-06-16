//
//  User.swift
//  itirafApp
//
//  Created by Emre on 1.10.2025.
//

struct User: Codable {
    var id: String?
    var username: String?
    var email: String
    var anonymous: Bool
    var socialLink: [Link]?
    let roles: [Role]
    
    enum CodingKeys: String, CodingKey {
        case id, username, email, anonymous, roles
        case socialLink = "social_links"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        email = try container.decode(String.self, forKey: .email)
        anonymous = try container.decodeIfPresent(Bool.self, forKey: .anonymous) ?? true
        roles = try container.decodeIfPresent([Role].self, forKey: .roles) ?? []
        socialLink = try container.decodeIfPresent([Link].self, forKey: .socialLink) ?? []
    }
}

struct Role: Codable {
    let name: RoleType
}

enum RoleType: String, Codable {
    case admin = "ADMIN"
    case user = "USER"
}
