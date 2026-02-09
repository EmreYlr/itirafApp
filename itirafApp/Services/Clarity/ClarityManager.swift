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
        #if DEBUG
            config.logLevel = .verbose
        #else
            config.logLevel = .none
        #endif
        
        ClaritySDK.initialize(config: config)
        
        ClaritySDK.setOnSessionStartedCallback { _ in
            if let clarityUrl = ClaritySDK.getCurrentSessionUrl() {
                CrashlyticsManager.shared.setClaritySessionLink(clarityUrl)
            }
        }
    }
    
    func setUserId(_ id: String) {
        ClaritySDK.setCustomUserId(id)
    }

    func clearUser() {
        ClaritySDK.setCustomUserId("")
    }
    
    func setCurrentScreen(name: String) {
        ClaritySDK.setCurrentScreenName(name)
    }
}
