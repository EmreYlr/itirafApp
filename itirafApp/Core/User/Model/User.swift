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
    
    enum CodingKeys: String, CodingKey {
        case id, username, email, anonymous
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        email = try container.decode(String.self, forKey: .email)
        anonymous = try container.decodeIfPresent(Bool.self, forKey: .anonymous) ?? true
    }
    
    init(id: String? = nil, username: String? = nil, email: String, isAnonymous: Bool = true) {
        self.id = id
        self.username = username
        self.email = email
        self.anonymous = isAnonymous
    }
}
