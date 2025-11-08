//
//  DeviceDetails.swift
//  itirafApp
//
//  Created by Emre on 8.11.2025.
//

import UIKit

struct DeviceDetails {
    
    static var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Bilinmiyor"
    }
    
    static var osVersion: String {
        return UIDevice.current.systemVersion
    }
    
    static let platform = "IOS"
    
    static var deviceModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        // Kaynak: https://www.theiphonewiki.com/wiki/Models
        switch identifier {
        case "iPhone14,7": return "iPhone 14"
        case "iPhone14,8": return "iPhone 14 Plus"
        case "iPhone15,2": return "iPhone 14 Pro"
        case "iPhone15,3": return "iPhone 14 Pro Max"
        case "iPhone15,4": return "iPhone 15"
        case "iPhone15,5": return "iPhone 15 Plus"
        case "iPhone16,1": return "iPhone 15 Pro"
        case "iPhone16,2": return "iPhone 15 Pro Max"
            
            // Simülatör
        case "i386", "x86_64", "arm64":
            return "Simulator (\(identifier))"
            
        default:
            return identifier
        }
    }
}
