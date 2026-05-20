//
//  UIColorTransformer.swift
//  Tracker
//
//  Created by Artem Yaroshenko on 20.05.2026.
//

import UIKit

final class UIColorTransformer: ValueTransformer {
    // MARK: - Static Properties
    static let name = NSValueTransformerName("UIColorTransformer")
    
    // MARK: - Override methods
    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let color = value as? UIColor else { return nil }
        do {
            return try NSKeyedArchiver.archivedData(
                withRootObject: color,
                requiringSecureCoding: true
            )
        } catch {
            return nil
        }
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        let color = try? NSKeyedUnarchiver.unarchivedObject(
            ofClass: UIColor.self,
            from: data
        )
        return color
    }
}
