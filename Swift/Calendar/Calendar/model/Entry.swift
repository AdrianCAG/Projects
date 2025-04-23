//
//  Entry.swift
//  Calendar
//
//  Created by Adrian on 4/22/25.
//

import Foundation



class Entry: CustomStringConvertible, Equatable {
    private let date: Date
    private let time: Time
    private let label: String
    private var intervalOfRepetition: Int = 0
    
    init(_ date: Date, _ time: Time, _ label: String) {
        self.date = date
        self.time = time
        self.label = label
    }
    
    // Getters
    var getLabel: String {
        return label
    }
    
    var getDate: Date {
        return date
    }
    
    var getTime: Time {
        return time
    }
    
    var getIntervalOfRepetition: Int {
        return intervalOfRepetition
    }
    
    var isRepeating: Bool {
        return intervalOfRepetition != 0
    }
    
    
    // Setter
    func setRepeating(_ newValue: Int) {
        intervalOfRepetition = newValue
    }
    
    static func == (lhs: Entry, rhs: Entry) -> Bool {
        return lhs.date == rhs.date &&
               lhs.time == rhs.time &&
               lhs.label == rhs.label &&
               lhs.intervalOfRepetition == rhs.intervalOfRepetition
    }
    
    var description: String {
        return String(describing: type(of: self))
    }
    
}
