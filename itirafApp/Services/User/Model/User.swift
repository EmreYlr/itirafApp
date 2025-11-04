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
    let roles: [Role]
    
    enum CodingKeys: String, CodingKey {
        case id, username, email, anonymous, roles
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        email = try container.decode(String.self, forKey: .email)
        anonymous = try container.decodeIfPresent(Bool.self, forKey: .anonymous) ?? true
        roles = try container.decodeIfPresent([Role].self, forKey: .roles) ?? []
    }
    
    init(id: String? = nil, username: String? = nil, email: String, isAnonymous: Bool = true, roles: [Role] = []) {
        self.id = id
        self.username = username
        self.email = email
        self.anonymous = isAnonymous
        self.roles = roles
    }
}

struct Role: Codable {
    let name: RoleType
}

enum RoleType: String, Codable {
    case admin = "ADMIN"
    case user = "USER"
}
