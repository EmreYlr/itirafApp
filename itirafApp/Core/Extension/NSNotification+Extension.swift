//
//  NSNotification+Extension.swift
//  itirafApp
//
//  Created by Emre on 24.09.2025.
//

import Foundation

extension NSNotification.Name {
    //AUTH
    static let userDidLogout = NSNotification.Name("userDidLogout")
    static let loginRequired = NSNotification.Name("loginRequired")
    
    //CHANNEL
    static let channelDidChange = NSNotification.Name("channelDidChange")
}
