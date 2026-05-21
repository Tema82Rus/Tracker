//
//  CoreDataTransformers.swift
//  Tracker
//
//  Created by Artem Yaroshenko on 20.05.2026.
//

import Foundation

enum CoreDataTransformers {
    static func register() {
        ValueTransformer.setValueTransformer(
            UIColorTransformer(),
            forName: UIColorTransformer.name
        )
        ValueTransformer.setValueTransformer(
            WeekdayScheduleTransformer(),
            forName: WeekdayScheduleTransformer.name
        )
    }
}
