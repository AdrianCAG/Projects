//
//  main.swift
//  Calendar
//
//  Created by Adrian on 4/22/25.
//

import Foundation



let myCal = Calendar(Date(17, 8, 2022))
myCal.email = "myCalOfficial@internet.com"

let tomorrow = Date(16, 8, 2022)
let nextWeek = Date(3, 9, 2022)
let nextMonth = Date(20, 9, 2022)

let coffee = Reminder(tomorrow, Time(6, 0), "Buy coffee")
coffee.setNote("Some coffee note")
myCal.addEntry(coffee)
myCal.addEntry(Event(nextWeek, Time(15, 30), "Wash car"))

let m = Meeting(nextMonth, Time(9, 0), "Programming")
m.addAttendee("max@uni.com")
m.addAttendee("geo@uni.com")
m.addAttendee("rex@uni.com")
myCal.addEntry(m)

m.sendInvites()
print()

myCal.printEntries()

print()
print(myCal.email)

print()
let entries = myCal.getEntries()[1] as! Event
print(entries.getReminder().getLabel)
