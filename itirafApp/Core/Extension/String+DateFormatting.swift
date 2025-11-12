//
//  String+DateFormatting.swift
//  itirafApp
//
//  Created by Emre on 27.10.2025.
//

import Foundation

//Date Formatter
extension String {
    func formattedDate() -> String? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = isoFormatter.date(from: self) else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "tr_TR")
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "d/M/yyyy"
        
        return dateFormatter.string(from: date)
    }
    
    func formattedTime() -> String? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = isoFormatter.date(from: self) else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "tr_TR")
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter.string(from: date)
    }
    
    func formattedDateTime() -> String? {
        guard let time = formattedTime(), let date = formattedDate() else { return nil }
        return "\(time) \(date)"
    }
}
//Relative Date Formatter
extension String {
    private func toDateFromISO() -> Date? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return isoFormatter.date(from: self)
    }
    
    func relativeTimeString() -> String? {
        guard let date = toDateFromISO() else { return nil }
        let calendar = Calendar.current
        let now = Date()
        
        let components = calendar.dateComponents([.minute, .hour, .day], from: date, to: now)
        
        if calendar.isDateInToday(date) {
            if let hours = components.hour, hours < 1 {
                let minutes = components.minute ?? 0
                if minutes < 1 {
                    return "1d önce"
                } else {
                    return "\(minutes)d önce"
                }
            } else if let hours = components.hour {
                return "\(hours)s önce"
            }
        } else if let days = components.day {
            return "\(days)g önce"
        }
        
        return nil
    }
}
