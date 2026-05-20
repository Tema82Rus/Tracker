//
//  TrackerStoreProtocol.swift
//  Tracker
//
//  Created by Artem Yaroshenko on 20.05.2026.
//

import Foundation

/// Хранилище для работы с трекерами и категориями.
protocol TrackerStoreProtocol {
    func fetchAllCategories() throws -> [TrackerCategory]
    func addTracker(_ tracker: Tracker, toCategory categoryTitle: String) throws
    func markTracker(_ trackerId: UUID, asCompleted  date: Date, isCompleted: Bool) throws
}
