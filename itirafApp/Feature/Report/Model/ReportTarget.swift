//
//  ReportTarget.swift
//  itirafApp
//
//  Created by Emre on 11.12.2025.
//

enum ReportTarget {
    case confession(messageId: Int)
    case room(roomId: String)
    case comment(replyId: Int)
}
