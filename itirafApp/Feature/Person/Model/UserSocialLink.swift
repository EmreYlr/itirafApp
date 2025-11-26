//
//  SocialLink.swift
//  itirafApp
//
//  Created by Emre on 31.10.2025.
//

import Foundation

struct UserSocialLink: Codable {
    var links: [Link]
}

struct Link: Codable {
    var id, username: String
    let platform: SocialPlatform
    let url: String
    let verified: Bool
    var visible: Bool
    let displayOrder: Int?
    let createdAt: String?
}

enum SocialPlatform: String, CaseIterable, Codable {
    case twitter = "twitter"
    case instagram = "instagram"

    var displayName: String {
        switch self {
        case .twitter: return "X (Twitter)"
        case .instagram: return "Instagram"
        }
    }
    
    var iconName: String {
        switch self {
        case .twitter:
            return "icon_x"
        case .instagram:
            return "icon_instagram"
        }
    }
    
    var baseURL: String {
        switch self {
        case .twitter: return "https://twitter.com/"
        case .instagram: return "https://www.instagram.com/"
        }
    }
}
