//
//  HabitMode + Enum.swift
//  Tracker
//
//  Created by Artem Yaroshenko on 24.05.2026.
//

import Foundation

enum HabitMode {
    case create
    case edit(Tracker)
    
    static func == (lhs: HabitMode, rhs: HabitMode) -> Bool {
        switch (lhs, rhs) {
        case (.create, .create):
            return true
        case (.edit(let lhsTracker), .edit(let rhsTracker)):
            return lhsTracker.id == rhsTracker.id
        default:
            return false
        }
    }
    
    var buttonTitle: String {
        switch self {
        case .create:
            return "Создать"
        case .edit:
            return "Сохранить"
        }
    }
    
    var navigationTitle: String {
        switch self {
        case .create:
            return "Новая привычка"
        case .edit:
            return "Редактирование привычки"
        }
    }
}
