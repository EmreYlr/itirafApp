//
//  ClarityManager.swift
//  itirafApp
//
//  Created by Emre on 28.11.2025.
//

import Foundation
import Clarity
import UIKit

final class ClarityManager {

    static let shared = ClarityManager()

    private init() {}

    func setup() {
        let config = ClarityConfig(projectId: Constants.clarityKey)

        config.logLevel = .verbose
        
        ClaritySDK.initialize(config: config)
    }
    
    func setUserId(_ id: String) {
        ClaritySDK.setCustomUserId(id)
    }

    func clearUser() {
        ClaritySDK.setCustomUserId("")
    }
}
