//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Artem Yaroshenko on 30.05.2026.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackersVCSnapshotTests: XCTestCase {
    func testTrackerVCMain() throws {
        let vc = TabBarController()

        _ = vc.view
        vc.view.setNeedsLayout()
        vc.view.layoutIfNeeded()
        waitForAsyncOperations()
        
        assertSnapshot(
            of: vc,
            as: .image,
            named: "mainScreen",
            record: false
        )
    }
    
    /// Вспомогательная функция для ожидания асинхронных операций
      private func waitForAsyncOperations() {
          let expectation = XCTestExpectation(
              description: "Wait for async operations in TabBarController"
          )
          
          // Даём небольшой буфер времени для завершения инициализации
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
              expectation.fulfill()
          }
          
          wait(for: [expectation], timeout: 1.0)
      }
}
