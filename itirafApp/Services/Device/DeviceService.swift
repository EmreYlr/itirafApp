//
//  DeviceService.swift
//  itirafApp
//
//  Created by Emre on 8.11.2025.
//

import Alamofire

protocol DeviceServiceProtocol {
    func registerDeviceToken(_ token: String,  notificationEnabled: Bool) async throws
}

final class DeviceService: DeviceServiceProtocol {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func registerDeviceToken(_ token: String, notificationEnabled: Bool) async throws {
        let parameters: [String: Any] = [
            "token": token,
            "platform": DeviceDetails.platform,
            "appVersion": DeviceDetails.appVersion,
            "deviceModel": DeviceDetails.deviceModel,
            "osVersion": DeviceDetails.osVersion,
            "pushEnabled": notificationEnabled
        ]

        let _: Empty = try await networkService.request(
            endpoint: Endpoint.Device.registerDevices,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
    }
}
