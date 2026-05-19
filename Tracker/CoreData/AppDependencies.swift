//
//  AppDependencies.swift
//  Tracker
//
//  Created by Artem Yaroshenko on 19.05.2026.
//

import UIKit
internal import CoreData

final class AppDependencies {
    // MARK: - Static Properties
    static let shared = AppDependencies()
    
    // MARK: - Private Properties
    private let context: NSManagedObjectContext
    
    // MARK: - Private Initialisers
    private init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate не найден")
        }
        self.context = appDelegate.persistentContainer.viewContext
    }
    
    // MARK: - Public Methods
    func makeTrackerStore() -> TrackerStoreProtocol {
        let context = self.context
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
        return TrackerRecordStore(context: context)
    }
}

