//
//  RecordStoreProtocol.swift
//  Tracker
//
//  Created by Artem Yaroshenko on 20.05.2026.
//

import Foundation

/// Хранилище для работы с записями выполнения трекеров.
protocol RecordStoreProtocol {
    func countRecords(for trackerId: UUID) throws -> Int
    func fetchAllRecords() throws -> [TrackerRecord]
    func addRecord(trackerId: UUID, date: Date) throws
    func removeRecord(trackerId: UUID, date: Date) throws
}
