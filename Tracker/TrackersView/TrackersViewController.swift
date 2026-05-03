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
    
    private lazy var leftBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(resource: .addTracker),
            style: .plain,
            target: self,
            action: #selector(didTapButton)
        )
        button.tintColor = .blackDay
        //if #available(iOS 26.0, *) { button.hidesSharedBackground = true }
        return button
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.calendar.firstWeekday = 2
        datePicker.date = currentDate
        datePicker.tintColor = .blackDay
        return datePicker
    }()
    
    private lazy var trackersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 167, height: 148)
        layout.minimumInteritemSpacing = 9
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TrackersCollectionViewCell.self,
                                forCellWithReuseIdentifier: TrackersCollectionViewCell.reuseIdentifier
        )
        collectionView.register(SupplementaryView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SupplementaryView.reuseIndentifierHeader
        )
        return collectionView
    }()
    
    private var categories: [TrackerCategory]?
    private var visibleCategories: [TrackerCategory]?
    private var completedTrackers: Set<TrackerRecord>?
    private var currentDate = Date()
    private var selectedDate: Date?
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        configurationNavBar()
        trackersCollectionView.dataSource = self
        trackersCollectionView.delegate = self
        setupTestData()
    }
    
    // MARK: - Private Methods
    private func setupTestData() {
        let testTrackers = [
            Tracker(id: UUID(),
                    title: "Зарядка утром",
                    color: .systemGreen,
                    emoji: "🏋️‍♀️",
                    timeTable: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
                   ),
            Tracker(id: UUID(),
                    title: "Поливать цветы",
                    color: .systemPink,
                    emoji: "🌸",
                    timeTable: [.monday, .friday]
                   )
        ]
        categories = [TrackerCategory(title: "Важные привычки", trackers: testTrackers)]
        visibleCategories = categories
    }
    
    private func configurationNavBar() {
        navigationItem.leftBarButtonItem = leftBarButton
        
        let rightBarButton = UIBarButtonItem(customView: datePicker)
        if #available(iOS 26.0, *) { rightBarButton.hidesSharedBackground = true }
        navigationItem.rightBarButtonItem = rightBarButton
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
    }
    
    @objc private func didTapButton() {
        print("Tap plus button")
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        self.selectedDate = selectedDate
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Выбранная дата: \(formattedDate)")
        
    }
    
    private func setupViews() {
        view.addSubview(label)
        view.addSubview(imageView)
        view.addSubview(labelDizzy)
        view.addSubview(searchBar)
        view.addSubview(trackersCollectionView)
        
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
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            searchBar.searchTextField.leadingAnchor.constraint(equalTo: label.leadingAnchor),
            
            trackersCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackersCollectionView.leadingAnchor.constraint(equalTo: label.leadingAnchor),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCollectionViewCell.reuseIdentifier,
                                                            for: indexPath) as? TrackersCollectionViewCell else { return UICollectionViewCell()}
        cell.backgroundColor = .clear
        cell.setupCell(title: "Поливать растения")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = SupplementaryView.reuseIndentifierHeader
        case UICollectionView.elementKindSectionFooter:
            id = SupplementaryView.reuseIndentifierFooter
        default:
            fatalError("Unsupported supplementary view kind: \(kind)")
        }
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? SupplementaryView else {
            fatalError("Failed to dequeue supplementary view of kind: \(kind) with identifier: \(id)")
        }
        view.setupHeader(title: "Домашний уют")
        return view
    }
}


// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let header = SupplementaryView(frame: .zero)
        header.setupHeader(title: "Домашний уют")
        return header.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                     height: UIView.layoutFittingCompressedSize.height)
        )
    }
}
