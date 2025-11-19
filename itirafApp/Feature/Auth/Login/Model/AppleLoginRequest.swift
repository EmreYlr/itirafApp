//
//  AppleLoginRequest.swift
//  itirafApp
//
//  Created by Emre on 19.11.2025.
//
import Foundation

struct AppleLoginRequest: Encodable {
    let identityToken: String
    let firstName: String?
    let lastName: String?
    let email: String?
}
