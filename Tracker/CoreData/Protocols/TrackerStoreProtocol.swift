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
    func togglePin(for trackerId: UUID) throws
    func fetchAllPinnedTrackerIds() throws -> [UUID]
    func deleteTracker(id: UUID) throws
    func updateTracker(newTracker: Tracker, categoryTitle: String?) throws
    func fetchCategoryForTracker(trackerId: UUID) throws -> String?
}
