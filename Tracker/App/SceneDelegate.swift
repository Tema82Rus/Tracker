//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Artem Yaroshenko on 01.04.2026.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        
        let vc = TabBarController()
        window.rootViewController = vc
        
        self.window = window
        self.window?.makeKeyAndVisible()
    }
}
