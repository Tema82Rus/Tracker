//
//  Tracker.swift
//  Tracker
//
//  Created by Artem Yaroshenko on 14.04.2026.
//

import UIKit

struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let timeTable: Set<WeekDay>
}
