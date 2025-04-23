//
//  Event.swift
//  Calendar
//
//  Created by Adrian on 4/22/25.
//

import Foundation



class Event: Entry {
    private var reminder: Reminder

    // REQUIRES: date, time, label != nil, date is in the future
    init(_ date: Date, _ time: Time, _ label: String, _ reminder: Reminder? = nil) {
        self.reminder = reminder ?? Reminder(date, time, label)
        super.init(date, time, label)
    }

    // Getter for reminder
    func getReminder() -> Reminder {
        return reminder
    }

    func setReminder(r: Reminder) {
        self.reminder = r
    }
}
