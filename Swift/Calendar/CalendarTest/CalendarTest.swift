//
//  CalendarTest.swift
//  CalendarTest
//
//  Created by Adrian on 4/23/25.
//

import XCTest


final class CalendarTest: XCTestCase {
    private var calendar: Calendar = Calendar(Date(0, 0, 000))
    var d: Date = Date(0, 0, 0)

    override func setUpWithError() throws {
        d = Date(11, 12, 2013)
        calendar = Calendar(d)
    }


    func testConstructor() throws {
        let entries = [Entry]()
        
        XCTAssertEqual(entries, calendar.getEntries())
        XCTAssertEqual(d, calendar.getCurrentDate())
    }
    
    func testEmail() {
        calendar.email = "abcd@hotmail.com"
        XCTAssertEqual("abcd@hotmail.com", calendar.email);
        calendar.email = "maxjaxhax@ubcxsc.org"
        XCTAssertEqual("maxjaxhax@ubcxsc.org", calendar.email);
    }
    
    func testEntries() {
        let nextWeek: Date = Date(19, 12, 2013)
        let noon: Time = Time(12, 0)
        let evening: Time = Time(21, 20)
        
        let e1: Entry = Reminder(nextWeek, noon, "Buy Juice")
        let e2: Entry = Event(nextWeek, evening, "Drink Juice")
        let e3: Entry = Meeting(nextWeek, noon, "Programming")
        
        calendar.addEntry(e1)
        calendar.addEntry(e2)
        calendar.addEntry(e3)
        
        XCTAssertEqual(3, calendar.getEntries().count)
        XCTAssertTrue(calendar.getEntries().contains(e2))
        calendar.removeEntry(e3)
        XCTAssertEqual(2, calendar.getEntries().count)
    }

}
