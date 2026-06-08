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
        case .first: return NSLocalizedString("onboarding.first.page", comment: "Track only\nwhat you want")
        case .second: return NSLocalizedString("onboarding.second.page", comment: "Even if it is\nnot liters of water and yoga")
        }
    }
    
    var buttonTitle: String { NSLocalizedString("onboarding.button", comment: "These are the technologies!") }
}
