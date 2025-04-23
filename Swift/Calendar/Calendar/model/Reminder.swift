//
//  Reminder.swift
//  Calendar
//
//  Created by Adrian on 4/22/25.
//

import Foundation



class Reminder: Entry {
    private var note: String
    
    override init(_ date: Date, _ time: Time, _ label: String) {
        self.note = ""
        super.init(date, time, label)
    }
    
    // Getters
    func getNot() -> String {
        if note.isEmpty {
            return "No note added"
        } else {
            return note
        }
    }
    
    // Setters
    func setNote(_ note: String) { self.note = note }
    
}
