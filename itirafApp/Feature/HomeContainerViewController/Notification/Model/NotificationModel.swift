//
//  NotificationModel.swift
//  itirafApp
//
//  Created by Emre on 18.11.2025.
//

struct NotificationModel: Codable {
    let page, limit, totalRows, totalPages: Int
    var data: [NotificationItem]
}

struct NotificationItem: Codable, Hashable {
    let id, title, body: String
    let type: NotificationEventType
    var seen: Bool
    let createdAt: String
    
    static func == (lhs: NotificationItem, rhs: NotificationItem) -> Bool {
        return lhs.id == rhs.id &&
        lhs.seen == rhs.seen    
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
