//
//  String+DateFormatting.swift
//  itirafApp
//
//  Created by Emre on 27.10.2025.
//

import Foundation

import Foundation

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
