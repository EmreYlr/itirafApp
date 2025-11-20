//
//  GoogleLoginRequest.swift
//  itirafApp
//
//  Created by Emre on 20.11.2025.
//
import Foundation

struct GoogleLoginRequest: Encodable {
    let idToken: String
    let email: String?
    let firstName: String?
    let lastName: String?
}
