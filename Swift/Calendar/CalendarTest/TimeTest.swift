//
//  TimeTest.swift
//  Calendar
//
//  Created by Adrian on 4/23/25.
//

import XCTest


final class TimeTest: XCTestCase {
    private var time1 = Time(0, 0)
    private var time2 = Time(0, 0)
    private var time3 = Time(0, 0)
    private var time4 = Time(0, 0)
    
    
    override func setUpWithError() throws {
        time1 = Time(0, 0)
        time2 = Time(10, 13)
        time3 = Time(20, 45)
        time4 = Time(13, 2)
    }
    
    func testConstructor() {
        XCTAssertEqual("00", time1.getHours());
        XCTAssertEqual("00", time1.getMinutes());

        XCTAssertEqual("10", time2.getHours());
        XCTAssertEqual("13", time2.getMinutes());

        XCTAssertEqual("20", time3.getHours());
        XCTAssertEqual("45", time3.getMinutes());
    }
    
    func testTimeIn24Hours() {
        XCTAssertEqual("00:00", time1.timeIn24Hours());
        XCTAssertEqual("10:13", time2.timeIn24Hours());
        XCTAssertEqual("20:45", time3.timeIn24Hours());
        XCTAssertEqual("13:02", time4.timeIn24Hours());
    }
    
    func testTimeIn12Hours() {
        XCTAssertEqual("12:00", time1.timeIn12Hours());
        XCTAssertEqual("10:13", time2.timeIn12Hours());
        XCTAssertEqual("8:45", time3.timeIn12Hours());
        XCTAssertEqual("1:02", time4.timeIn12Hours());
        time4 = Time(12, 5);
        XCTAssertEqual("12:05", time4.timeIn12Hours());
    }
}
