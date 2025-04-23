//
//  Time.swift
//  Calendar
//
//  Created by Adrian on 4/22/25.
//

import Foundation



class Time {
    private let hours: Int
    private let minutes: Int
    
    init(_ hours: Int, _ minutes: Int) {
        self.hours = hours
        self.minutes = minutes
    }
    
    // Getters
    func getHours() -> String { return addPrefix(hours) }
    func getMinutes() -> String { return addPrefix(minutes) }
    func timeInt24Hours() -> String { return "\(addPrefix(hours)) : \(getMinutes())" }
    
    func timeInt12Hours() -> String {
        if hours > 12 {
            return "\(hours - 12) : \(getMinutes())"
        } else if hours == 0 {
            return "\(12) : \(getMinutes())"
        } else {
            return "\(hours) : \(getMinutes())"
        }
    }
    
    // Setters
    func addPrefix(_ i: Int) -> String {
        if i < 10 {
            return "0" + String(i)
        } else {
            return "" + String(i)
        }
    }
}
