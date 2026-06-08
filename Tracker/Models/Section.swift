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
        case .emoji: NSLocalizedString("newhabit.emoji.section", comment: "Emoji section")
        case .color: NSLocalizedString("newhabit.color.section", comment: "Color section")
        }
    }
}
