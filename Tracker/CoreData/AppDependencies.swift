//
//  AppDependencies.swift
//  Tracker
//
//  Created by Artem Yaroshenko on 19.05.2026.
//

import UIKit

final class AppDependencies {
    // MARK: - Static Properties
    static let shared = AppDependencies()
    
    // MARK: - Private Properties
    private let contextProvider: ManagedObjectContextProvider
    
    // MARK: - Private Initialisers
    private init(contextProvider: ManagedObjectContextProvider = AppDelegate.shared) {
        self.contextProvider = contextProvider
    }
    
    // MARK: - Public Methods
    func makeTrackerStore() -> TrackerStoreProtocol {
        let context = contextProvider.viewContext
        let categoryStore = TrackerCategoryStore(context: context)
        let trackerStore = TrackerStore(context: context, categoryStore: categoryStore)
        let recordStore = TrackerRecordStore(context: context)
        return TrackerStoreFacade(
            trackerStore: trackerStore,
            categoryStore: categoryStore,
            recordStore: recordStore
        )
    }
    
    func makeRecordStore() -> RecordStoreProtocol {
        return TrackerRecordStore(context: contextProvider.viewContext)
    }
}

