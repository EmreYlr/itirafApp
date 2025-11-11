//
//  NSNotification+Extension.swift
//  itirafApp
//
//  Created by Emre on 24.09.2025.
//

import Foundation

extension NSNotification.Name {
    //AUTH
    static let loginRequired = NSNotification.Name("loginRequired")
    
    //CHANNEL
    static let channelDidChange = NSNotification.Name("channelDidChange")
    
    //NOTIFICATION
    static let didTapPushNotification = NSNotification.Name("didTapPushNotification")
}
