//
//  Meeting.swift
//  Calendar
//
//  Created by Adrian on 4/22/25.
//

import Foundation

class Meeting: Event {
    private var attendees: [String]
    
    init(_ date: Date, _ time: Time, _ label: String) {
        attendees = []
        super.init(date, time, label)
    }
    
    // Getters
    func getAttendees() -> [String] { return attendees }
    
    
    // Setters
    func addAttendees(_ attendee: String) { attendees.append(attendee) }
    
    func removeAttendees(_ attendee: String) {
        if let index = attendees.firstIndex(where: { $0 == attendee }) {
            attendees.remove(at: index)
        }
    }
    
    
    func sendInvites() {
        for attendee in attendees {
            print("Inviting: \(attendee)")
        }
    }
    
}
