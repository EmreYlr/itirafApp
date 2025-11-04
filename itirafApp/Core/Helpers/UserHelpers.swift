//
//  UserHelpers.swift
//  itirafApp
//
//  Created by Emre on 4.11.2025.
//

extension User {
    func hasRole(_ role: RoleType) -> Bool {
        roles.contains { $0.name == role }
    }

    var isAdmin: Bool {
        hasRole(.admin)
    }

    var isUser: Bool {
        hasRole(.user)
    }
}
