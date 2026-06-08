//
//  SearchService.swift
//  Tracker
//
//  Created by Artem Yaroshenko on 30.05.2026.
//

import Foundation

protocol SearchServiceDelegate: AnyObject {
    func didUpdateSearchResults(_ filteredCategories: [TrackerCategory])
}

final class SearchService {
    
    weak var delegate: SearchServiceDelegate?
    private var allCategories: [TrackerCategory] = []
    
    func updateCategories(_ categories: [TrackerCategory]) {
        self.allCategories = categories
    }
    
    func filterCategories(searchText: String) {
        
        print("⚙️ SearchService: Фильтрация по тексту '\(searchText)'")
        
        if searchText.isEmpty {
            delegate?.didUpdateSearchResults(allCategories)
            return
        }
        
        let query = searchText.lowercased()
        var result: [TrackerCategory] = []
        
        for category in allCategories {
            var matchingTrackers: [Tracker] = []
            
            for tracker in category.trackers {
                if tracker.title.lowercased().contains(query) {
                    matchingTrackers.append(tracker)
                }
            }
            
            if !matchingTrackers.isEmpty {
                result.append(TrackerCategory(
                    title: category.title,
                    trackers: matchingTrackers
                ))
            }
        }
        
        print("⚙️ SearchService: Найдено категорий: \(result.count)")
        
        delegate?.didUpdateSearchResults(result)
    }
}

