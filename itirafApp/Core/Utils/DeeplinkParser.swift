//
//  DeeplinkParser.swift
//  itirafApp
//
//  Created by Emre on 11.11.2025.
//

import Foundation

struct DeeplinkParser {
    
    static func parse(url: URL) -> AppRoute? {
        let components = url.pathComponents
        
        guard components.count > 1 else {
            return .home
        }
        
        let routeType = components[1]
        
        switch routeType {
        case "confession":
            guard components.count > 2, let id = Int(components[2]) else {
                return nil
            }
            return .confessionDetail(id: id)
            
        case "passwordReset":
            guard components.count > 2 else {
                return nil
            }
            let token = components[2]
            return .passwordReset(token: token)
            
        default:
            return .home
        }
    }
}
