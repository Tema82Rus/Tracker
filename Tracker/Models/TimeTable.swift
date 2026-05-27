//
//  TimeTable.swift
//  Tracker
//
//  Created by Artem Yaroshenko on 14.04.2026.
//

import Foundation

enum WeekDay: Int, CaseIterable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    
    var title: String {
        switch self {
        case .monday: NSLocalizedString("monday", comment: "Monday")
        case .tuesday: NSLocalizedString("tuesday", comment: "Tuesday")
        case .wednesday: NSLocalizedString("wednesday", comment: "Wednesday")
        case .thursday: NSLocalizedString("thursday", comment: "Thursday")
        case .friday: NSLocalizedString("friday", comment: "Friday")
        case .saturday: NSLocalizedString("saturday", comment: "Saturday")
        case .sunday: NSLocalizedString("sunday", comment: "Sunday")
        }
    }
    
    var shortTitle: String {
        switch self {
        case .monday: NSLocalizedString("monday.short", comment: "Mon")
        case .tuesday: NSLocalizedString("tuesday.short", comment: "Tue")
        case .wednesday: NSLocalizedString("wednesday.short", comment: "Wed")
        case .thursday: NSLocalizedString("thursday.short", comment: "Thu")
        case .friday: NSLocalizedString("friday.short", comment: "Fri")
        case .saturday: NSLocalizedString("saturday.short", comment: "Sat")
        case .sunday: NSLocalizedString("sunday.short", comment: "Sun")
        }
    }
    
    var calendarWeekDay: Int {
        switch self {
        case .monday: 2
        case .tuesday: 3
        case .wednesday: 4
        case .thursday: 5
        case .friday: 6
        case .saturday: 7
        case .sunday: 1
        }
    }
}
