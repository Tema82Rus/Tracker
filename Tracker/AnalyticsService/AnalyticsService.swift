//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Artem Yaroshenko on 01.06.2026.
//

import Foundation
import AppMetricaCore

struct AnalyticsService {
    enum screenEvent: String {
        case open
        case close
        case click
    }
    
    enum ParamsKey: String {
        case screen
        case item
    }
    
    enum ParamsValue: String {
        case main
        case add_track
        case filter
        case edit
        case delete
        case track
    }
    
    private static let apiKey: String = "411f302f-6c44-462a-b429-cd0d0da7b891"
    
    static func setupAnalyticsService() {
        guard let configuration = AppMetricaConfiguration(apiKey: apiKey) else {
            print("Ошибка конфигурации AppMetrica")
            return
        }
        
        AppMetrica.activate(with: configuration)
        print("AppMetrica успешно инициализирована")
    }
    
    static func report(event: screenEvent, params: [ParamsKey: ParamsValue] = [:]) {
        let serializedParams = params.reduce(into: [String: String]()) { acc, pair in
            acc[pair.key.rawValue] = pair.value.rawValue
        }
        AppMetrica.reportEvent(name: event.rawValue, parameters: serializedParams) { (error: Error?) in
            if let error {
                print("❌ Ошибка: \(error)")
            } else {
                print("✅ Отправлено")
            }
        }
    }
}
