//
//  AppRoute.swift
//  itirafApp
//
//  Created by Emre on 11.11.2025.
//

enum AppRoute {
    case home
    case confessionDetail(id: Int)
    case passwordReset(token: String)
    
    case directMessage(roomId: String, username: String)
    case myConfessions
}
