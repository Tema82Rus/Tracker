//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Artem Yaroshenko on 01.04.2026.
//

import UIKit

final class TrackersViewController: UIViewController {
    // MARK: - Private Properties
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Трекеры"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.sizeToFit()
        label.textAlignment = .center
        label.textColor = .blackDay
        return label
    }()
    
    private lazy var labelDizzy: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Что будем отслеживать?"
        label.textColor = .blackDay
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.sizeToFit()
        label.textAlignment = .center
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(resource: .dizzy)
        return imageView
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Поиск"
        searchBar.backgroundImage = UIImage()
        return searchBar
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraint()
        
        configurationNavBar()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        view.addSubview(label)
        view.addSubview(imageView)
        view.addSubview(labelDizzy)
        view.addSubview(searchBar)
    }
    
    private func setupConstraint() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            labelDizzy.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            labelDizzy.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            searchBar.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: label.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        //TODO: fix constraint for UI elements
    }
    
    private func configurationNavBar() {
        let leftBarButton = UIBarButtonItem(
            image: UIImage(resource: .addTracker),
            style: .plain,
            target: self,
            action: #selector(didTapButton)
        )
        leftBarButton.tintColor = .blackDay
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        let rightBarButton = UIBarButtonItem(
            title: "Дата",
            style: .plain,
            target: self,
            action: #selector(openDatePicker)
        )
        rightBarButton.tintColor = .blackDay
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @objc private func didTapButton() {
        print("Tap plus button")
        //        let statisticsVC = StatisticsViewController()
        //        self.navigationController?.pushViewController(statisticsVC, animated: true)
    }
    
    @objc private func openDatePicker() {
        print("Open view of date picker")
    }
}
