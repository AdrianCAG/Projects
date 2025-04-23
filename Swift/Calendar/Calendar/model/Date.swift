//
//  Date.swift
//  Calendar
//
//  Created by Adrian on 4/22/25.
//

import Foundation



class Date: Equatable {
    private let month: Int
    private let date: Int
    private let year: Int
    
    init(_ date: Int, _ month: Int, _ year: Int) {
        self.month = month
        self.date = date
        self.year = year
    }
    
    // Getters
    func getMounth() -> Int { return month }
    func getDate() -> Int { return date }
    func getYear() -> Int { return year }
    func getDateShort() -> String { return "\(date)/\(month)/\(year)"}
    
    func getDatePretty() -> String {
        var monthName = ""
        
        switch month {
        case 1:
            monthName = "January"
        case 2:
            monthName = "February"
        case 3:
            monthName = "March"
        case 4:
            monthName = "April"
        case 5:
            monthName = "May"
        case 6:
            monthName = "June"
        case 7:
            monthName = "July"
        case 8:
            monthName = "August"
        case 9:
            monthName = "September"
        case 10:
            monthName = "October"
        case 11:
            monthName = "November"
        case 12:
            monthName = "December"
        default:
            monthName = "Unknown"
        }
        
        return "\(monthName) \(date)\(ordinalIndicator()), \(year)"
    }
    
    func ordinalIndicator() -> String {
        if date >= 10 && date <= 20 {
            return "th"
        }
        
        let determinant = date % 10
        
        switch determinant {
            case 1: return "st"
            case 2: return "nd"
            case 3: return "rd"
            default: 
                return "th"
        }
    }
    
    static func == (lhs: Date, rhs: Date) -> Bool {
        return lhs.month == rhs.month &&
               lhs.date == rhs.date &&
               lhs.year == rhs.year
    }
}
