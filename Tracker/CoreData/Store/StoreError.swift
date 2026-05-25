//
//  StoreError.swift
//  Tracker
//
//  Created by Artem Yaroshenko on 20.05.2026.
//

import Foundation

enum StoreError: Error {
    case noAppDelegate
    case failedToSave(String)
    case fetchFailed(String)
    case decodingError(String)
    case trackerNotFound
    case categoryNotFound
    case recordNotFound
    case categoryAlreadyExists
}
