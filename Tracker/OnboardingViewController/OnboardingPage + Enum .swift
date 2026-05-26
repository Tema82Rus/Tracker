//
//  OnboardingPage + Enum .swift
//  Tracker
//
//  Created by Artem Yaroshenko on 26.05.2026.
//

import UIKit

enum OnboardingPage: CaseIterable {
    case first
    case second
    
    var image: UIImage? {
        switch self {
        case .first: return UIImage(named: "onboarding1")
        case .second: return UIImage(named: "onboarding2")
        }
    }
    
    var title: String {
        switch self {
        case .first: return "Отслеживайте только \n то, что хотите"
        case .second: return "Даже если это \n не литры воды и йога"
        }
    }
    
    var buttonTitle: String { "Вот это технологии!" }
}
