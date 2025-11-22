//
//  UserFriendlyError.swift
//  itirafApp
//
//  Created by Emre on 22.11.2025.
//

import Foundation

protocol UserFriendlyError: LocalizedError {
    var title: String { get }
    var message: String { get }
}

extension UserFriendlyError {
    var errorDescription: String? {
        return message
    }
}
