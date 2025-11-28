//
//  CrashlyticsManager.swift
//  itirafApp
//
//  Created by Emre on 10.11.2025.
//

import FirebaseCrashlytics

final class CrashlyticsManager {
    static let shared = CrashlyticsManager()
    private let crashlytics = Crashlytics.crashlytics()
    
    private init() { }
    
    func sentNonFatal(_ error: Error) {
        crashlytics.record(error: error)
    }
    
    func logMessage(_ message: String) {
        crashlytics.log(message)
    }
    
    func setUserID(_ userID: String) {
        crashlytics.setUserID(userID)
    }
    
    func isUserAnonymous(_ isAnonymous: Bool) {
        crashlytics.setCustomValue(isAnonymous, forKey: "is_anonymous_user")
    }
    
    func setClaritySessionLink(_ url: String) {
        setValue(url, forKey: "claritySessionLink")
    }
    
    
    private func setValue(_ value: String, forKey key: String) {
        crashlytics.setCustomValue(value, forKey: key)
    }
    
    func sentNetworkError(_ error: Error, endpoint: String, method: String, statusCode: Int
    ) {
        let nsError = error as NSError
        var userInfo = nsError.userInfo

        userInfo["NetworkErrorDetails"] = [
            "endpoint": endpoint,
            "method": method,
            "statusCode": statusCode
        ]
        
        let enrichedError = NSError(
            domain: nsError.domain,
            code: nsError.code,
            userInfo: userInfo
        )

        crashlytics.record(error: enrichedError)
    }
}
