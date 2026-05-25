//
//  TrackerStoreFacade.swift
//  Tracker
//
//  Created by Artem Yaroshenko on 19.05.2026.
//

import Foundation

final class TrackerStoreFacade: TrackerStoreProtocol {
    // MARK: - Private Properties
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore
    
    // MARK: - Initialisers
    init(trackerStore: TrackerStore, categoryStore: TrackerCategoryStore, recordStore: TrackerRecordStore) {
        self.trackerStore = trackerStore
        self.categoryStore = categoryStore
        self.recordStore = recordStore
    }
    
    // MARK: - Public Methods
    func fetchAllCategories() throws -> [TrackerCategory] {
        return try categoryStore.fetchAllCategories()
    }
    
    func addTracker(_ tracker: Tracker, toCategory categoryTitle: String) throws {
        try trackerStore.addTracker(tracker, toCategory: categoryTitle)
    }
    
    func markTracker(_ trackerId: UUID, asCompleted date: Date, isCompleted: Bool) throws {
        if isCompleted {
            try recordStore.addRecord(trackerId: trackerId, date: date)
        } else {
            try recordStore.removeRecord(trackerId: trackerId, date: date)
        }
    }
    
    func togglePin(for trackerId: UUID) throws {
        try trackerStore.togglePin(for: trackerId)
    }
    
    func fetchAllPinnedTrackerIds() throws -> [UUID] {
        return try trackerStore.fetchAllPinnedTrackerIds()
    }
    
    func deleteTracker(id: UUID) throws {
        try trackerStore.deleteTracker(id: id)
    }
    
    func updateTracker(newTracker: Tracker, categoryTitle: String?) throws {
        var categoryEntity: TrackerCategoryCoreData? = nil
        if let categoryTitle = categoryTitle {
            categoryEntity = try categoryStore.fetchCategoryCoreData(by: categoryTitle)
        }
        
        try trackerStore.updateTracker(newTracker: newTracker, category: categoryEntity)
    }
    
    func fetchCategoryForTracker(trackerId: UUID) throws -> String? {
        return try trackerStore.fetchCategoryForTracker(trackerId: trackerId)
    }
}

