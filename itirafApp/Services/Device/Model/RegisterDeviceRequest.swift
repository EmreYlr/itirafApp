//
//  RegisterDeviceRequest.swift
//  itirafApp
//
//  Created by Emre on 8.11.2025.
//

struct RegisterDeviceRequest: Encodable {
    let token: String
    let platform: String
    let appVersion: String
    let deviceModel: String
    let osVersion: String
}
