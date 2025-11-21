//
//  AppRoute.swift
//  itirafApp
//
//  Created by Emre on 11.11.2025.
//

enum AppRoute {
    case home
    case confessionDetail(id: Int, commentId: Int? = nil)
    case passwordReset(token: String)
    case directMessage(roomId: String, senderName: String, senderId: String)
    case myConfessions
    case requestDetail(requestId: String)
    case requestResponse(requestId: String)
    case moderation(messageId: Int)
}
