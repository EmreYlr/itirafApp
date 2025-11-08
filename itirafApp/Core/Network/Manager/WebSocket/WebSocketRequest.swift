//
//  WebSocketRequest.swift
//  itirafApp
//
//  Created by Emre on 28.10.2025.
//

struct WebSocketRequest: Codable {
    let type: String
    let data: WebSocketMessageData
}

struct WebSocketMessageData: Codable {
    let content: String
    let recipientId: String
}

struct SeenRequest: Codable {
    let type: String
}
