//
//  WeekdayScheduleTransformer.swift
//  Tracker
//
//  Created by Artem Yaroshenko on 20.05.2026.
//

import Foundation

final class WeekdayScheduleTransformer: ValueTransformer {
    // MARK: - Static Properties
    static let name = NSValueTransformerName("WeekdayScheduleTransformer")
    
    // MARK: - Override methods
    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        if let weekdays = value as? [WeekDay] {
            return encode(weekdays)
        }
        if let weekdaySet = value as? Set<WeekDay> {
            return encode(Array(weekdaySet))
        }
        return nil
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        let ints = (try? JSONDecoder().decode([Int].self, from: data)) ?? []
        return ints.compactMap { WeekDay(rawValue: $0) }
    }
    
    // MARK: - Private Methods
    private func encode(_ weekdays: [WeekDay]) -> Data? {
        let ints = weekdays.map { $0.rawValue }
        return try? JSONEncoder().encode(ints)
    }
}
