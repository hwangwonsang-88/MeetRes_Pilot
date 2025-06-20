//
//  Date+.swift
//  Meet_pilot
//
//  Created by 인스웨이브 on 6/20/25.
//

import Foundation

extension Date {
    static func yesterDay() -> Date {
        let today = Date()
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)
        return yesterday!
    }
}

extension Date {
    var nextDay: Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: 1, to: self)!
    }
    
    func adding30MinutesSafe() -> Date {
        return Calendar.current.date(byAdding: .minute, value: 30, to: self) ?? self
    }
}
