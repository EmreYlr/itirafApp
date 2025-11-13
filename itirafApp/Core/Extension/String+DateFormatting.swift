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
        let now = Date()
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.minute, .hour, .day], from: date, to: now)
        
        if let day = components.day, day > 0 {
            return "\(day)g önce"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour)sa önce"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute)dk önce"
        } else {
            return "az önce"
        }
    }
}
