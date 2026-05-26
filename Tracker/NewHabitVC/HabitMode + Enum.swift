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
        case (.create, .create): true
        case (.edit(let lhsTracker), .edit(let rhsTracker)): lhsTracker.id == rhsTracker.id
        default: false
        }
    }
    
    var buttonTitle: String {
        switch self {
        case .create: "Создать"
        case .edit: "Сохранить"
        }
    }
    
    var navigationTitle: String {
        switch self {
        case .create: "Новая привычка"
        case .edit: "Редактирование привычки"
        }
    }
}
