//
//  TrackerStoreFacade.swift
//  Tracker
//
//  Created by Artem Yaroshenko on 19.05.2026.
//

import Foundation
internal import CoreData

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
        let categoryEntity: TrackerCategoryCoreData
        if let existing = try categoryStore.fetchCategoryCoreData(by: categoryTitle) {
            categoryEntity = existing
        } else {
            _ = try categoryStore.createCategory(title: categoryTitle)
            guard let newCategory = try categoryStore.fetchCategoryCoreData(by: categoryTitle) else {
                throw StoreError.categoryNotFound
            }
            categoryEntity = newCategory
        }
        let trackerEntity = TrackerCoreData(context: trackerStore.context)
        trackerEntity.trackerId = tracker.id
        trackerEntity.nameTracker = tracker.title
        trackerEntity.colorTracker = tracker.color
        trackerEntity.emoji = tracker.emoji
        trackerEntity.setValue(tracker.timeTable, forKey: "schedule")
        trackerEntity.category = categoryEntity
        
        try trackerStore.saveContext()
    }
    
    func markTracker(_ trackerId: UUID, asCompleted date: Date, isCompleted: Bool) throws {
        if isCompleted {
            try recordStore.addRecord(trackerId: trackerId, date: date)
        } else {
            try recordStore.removeRecord(trackerId: trackerId, date: date)
        }
    }
    
    
}

