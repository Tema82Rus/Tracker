//
//  Section.swift
//  Tracker
//
//  Created by Artem Yaroshenko on 14.05.2026.
//

import Foundation

enum Section: Int, CaseIterable {
    case emoji
    case color
    
    var title: String {
        switch self {
        case .emoji: return "Emoji"
        case .color: return "Color"
        }
    }
}
