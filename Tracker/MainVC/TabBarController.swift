//
//  ViewController.swift
//  Tracker
//
//  Created by Artem Yaroshenko on 01.04.2026.
//

import UIKit

final class TabBarController: UITabBarController {
    // MARK: - Private Properties
    private var topDivider: UIView?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    // MARK: - Private Methods
    private func setupTabBar() {
        addTopDividerToBar()
        
        let trackersVC = TrackersViewController()
        let statisticsVC = StatisticsViewController()
        
        trackersVC.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(resource: .trackers), tag: 0)
        statisticsVC.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(resource: .stats), tag: 1)
        
        let trackersNavController = UINavigationController(rootViewController: trackersVC)
        let statisticsNavController = UINavigationController(rootViewController: statisticsVC)
        viewControllers = [trackersNavController, statisticsNavController]
    }
    
    private func addTopDividerToBar() {
        let divider = UIView()
        divider.backgroundColor = .appGray
        divider.translatesAutoresizingMaskIntoConstraints = false
        
        tabBar.addSubview(divider)
        
        NSLayoutConstraint.activate([
            divider.topAnchor.constraint(equalTo: tabBar.topAnchor),
            divider.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
   
}

