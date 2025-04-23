//
//  Calendar.swift
//  Calendar
//
//  Created by Adrian on 4/22/25.
//

import Foundation



class Calendar {
    private var _email: String
    private var entries: [Entry]
    private let currentDate: Date
    
    init(_ currentDate: Date) {
        self._email = ""
        self.currentDate = currentDate
        self.entries = []
    }
    
    var email: String {
        get { return _email }
        set { _email = newValue }
    }
    
    // Getters
    func getCurrentDate() -> Date { return currentDate }
    func getEntries() -> [Entry] { return entries }
    
    
    // Setters
    func addEntry(_ e: Entry) { entries.append(e) }
    
    func removeEntry(_ e: Entry) {
        if let index = entries.firstIndex(where: {$0 === e}) {
            entries.remove(at: index)
        }
    }
    
    
    func printEntries() {
        print("Today is \(currentDate.getDatePretty())")
        print("Upcoming:")

        for e in entries {
            // Adjust the width as needed (e.g., 20 characters for label)
            let formatted = String(format: "%-20s (%-10s): %@",
                                   (e.getLabel as NSString).utf8String!,
                                   (e.description as NSString).utf8String!,
                                   e.getDate.getDateShort())
            print(formatted)
        }
    }
}
