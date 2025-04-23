//
//  DateTest.swift
//  CalendarTest
//
//  Created by Adrian on 4/23/25.
//

import XCTest



final class DateTest: XCTestCase {
    private var testDate: Date = Date(0, 0, 0000)
    

    override func setUpWithError() throws {
        testDate = Date(5, 5, 2025)
    }


    func testInit() {
        XCTAssertEqual(5, testDate.getDate())
        XCTAssertEqual(5, testDate.getMounth())
        XCTAssertEqual(2025, testDate.getYear())
        
        testDate = Date(12, 8, 1800)
        XCTAssertEqual(12, testDate.getDate())
        XCTAssertEqual(8, testDate.getMounth())
        XCTAssertEqual(1800, testDate.getYear())

    }
    
    func testGetDateShort() {
        XCTAssertEqual("5/5/2025", testDate.getDateShort())
        testDate = Date(9, 12, 2021)
        XCTAssertEqual("9/12/2021", testDate.getDateShort())
    }
    
    func testGetDatePretty() {
        XCTAssertEqual("May 5th, 2025", testDate.getDatePretty())
        testDate =  Date(2, 2, 2018);
        XCTAssertEqual("February 2nd, 2018", testDate.getDatePretty());
        testDate = Date (3, 3, 2017);
        XCTAssertEqual("March 3rd, 2017", testDate.getDatePretty());
        testDate = Date(13, 4, 2020);
        XCTAssertEqual("April 13th, 2020", testDate.getDatePretty());
        testDate = Date(4, 5, 2018);
        XCTAssertEqual("May 4th, 2018", testDate.getDatePretty());
        testDate = Date(16, 6, 1952);
        XCTAssertEqual("June 16th, 1952", testDate.getDatePretty());
        testDate = Date(27, 7, 2012);
        XCTAssertEqual("July 27th, 2012", testDate.getDatePretty());
        testDate = Date(12, 8, 2017);
        XCTAssertEqual("August 12th, 2017", testDate.getDatePretty());
        testDate = Date(13, 9, 2017);
        XCTAssertEqual("September 13th, 2017", testDate.getDatePretty());
        testDate = Date(2, 10, 2019);
        XCTAssertEqual("October 2nd, 2019", testDate.getDatePretty());
        testDate = Date(29, 11, 2018);
        XCTAssertEqual("November 29th, 2018", testDate.getDatePretty());
        testDate = Date(20, 12, 2017);
        XCTAssertEqual("December 20th, 2017", testDate.getDatePretty());
    }
}
