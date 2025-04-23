//
//  EntryTest.swift
//  Calendar
//
//  Created by Adrian on 4/23/25.
//

import XCTest


enum Dummy {
    static let date = Date(0, 0, 0)
    static let time = Time(0, 0)
    
    static let reminder = Reminder(date, time, "")
    static let meeting = Meeting(date, time, "")
    static let event = Event(date, time, "")
}



final class EntryTest: XCTestCase {
    private var reminder = Dummy.reminder
    private var meeting = Dummy.meeting
    private var event = Dummy.event
    private var d1 = Dummy.date
    private var d2 = Dummy.date
    private var t1 = Dummy.time
    private var t2 = Dummy.time
    
    
    override func setUpWithError() throws {
            // More descriptive dates and times
            d1 = Date(5, 15, 2023)  // May 15, 2023
            d2 = Date(12, 31, 2024) // December 31, 2024
            t1 = Time(14, 30)       // 2:30 PM
            t2 = Time(8, 45)        // 8:45 AM
            
            // Assigning more descriptive labels
            event = Event(d1, t1, "Alice's graduation")
            meeting = Meeting(d2, t2, "End of year performance review")
            reminder = Reminder(d2, t1, "Plan the next project")
        }
        
    func testConstructor() {
        // Testing if dates and times match
        XCTAssertEqual(d1, event.getDate)
        XCTAssertEqual(d2, meeting.getDate)
        XCTAssertEqual(t1, event.getTime)
        XCTAssertEqual(t2, meeting.getTime)
        XCTAssertEqual("Alice's graduation", event.getLabel)
        XCTAssertEqual("Plan the next project", reminder.getLabel)
    }
    
    func testEntry() {
        meeting.setRepeating(182) // Repeating after 182 days (about 6 months)
        XCTAssertTrue(meeting.isRepeating)
        XCTAssertEqual(182, meeting.getIntervalOfRepetition)
        meeting.setRepeating(0) // No repetition
        XCTAssertFalse(meeting.isRepeating)
    }
    
    func testEvent() {
        event.setReminder(reminder)
        XCTAssertEqual(reminder, event.getReminder())
        
        reminder = Reminder(d1, t2, "Launch party for the new project")
        reminder.setNote("Prepare a speech")
        event.setReminder(reminder)
        XCTAssertEqual("Prepare a speech", event.getReminder().getNote())
    }
    
    func testMeeting() {
        var attendees = ["Max", "Hugo", "Jen"]
        meeting.addAttendee("Max")
        meeting.addAttendee("Hugo")
        meeting.addAttendee("Jen")
        
        XCTAssertEqual(attendees, meeting.getAttendee())
        
        if let index = attendees.firstIndex(where: {$0 == "Max"}) {
            attendees.remove(at: index)
        }
        
        meeting.removeAttendee("Max")
        XCTAssertEqual(attendees, meeting.getAttendee())
    }
    
    func testReminder() {
        XCTAssertEqual("No note added", reminder.getNote())
        reminder.setNote("Exercise more often")
        XCTAssertEqual("Exercise more often", reminder.getNote())
    }
}

