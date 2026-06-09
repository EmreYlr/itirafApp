//
//  Date+ISOFormatting.swift
//  itirafApp
//
//  Created by Emre on 27.10.2025.
//

import Foundation

extension Date {
    init?(isoStringWithFractionalSeconds isoString: String) {
        struct Static {
            static let formatter: ISO8601DateFormatter = {
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                return formatter
            }()
        }
        
        guard let date = Static.formatter.date(from: isoString) else {
            return nil
        }
        
        self = date
    }
    
    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
}
