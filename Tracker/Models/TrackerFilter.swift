//
//  TrackerFilter.swift
//  Tracker
//
//  Created by Artem Yaroshenko on 30.05.2026.
//

import Foundation

enum TrackerFilter: Int, CaseIterable {
    case all
    case today
    case completed
    case uncompleted
    
    var title: String {
        switch self {
        case .all: return NSLocalizedString("filter.all", comment: "All trackers")
        case .today: return NSLocalizedString("filter.today", comment: "Trackers for today")
        case .completed: return NSLocalizedString("filter.completed", comment: "Completed")
        case .uncompleted: return NSLocalizedString("filter.uncompleted", comment: "Not completed")
        }
    }

    var shouldShowCheckmark: Bool {
        return self == .completed || self == .uncompleted
    }

    var isStrictFilter: Bool {
        return shouldShowCheckmark
    }
}
