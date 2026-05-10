//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Artem Yaroshenko on 01.04.2026.
//

import UIKit

final class TrackersViewController: UIViewController {
    // MARK: - Private Properties
    private lazy var placeholderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let image = UIImageView(image: .star)
        image.contentMode = .scaleAspectFit
        image.widthAnchor.constraint(equalToConstant: 80).isActive = true
        image.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textColor = .blackDay
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.sizeToFit()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        stack.addArrangedSubview(image)
        stack.addArrangedSubview(label)
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        return view
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.calendar.firstWeekday = 2
        datePicker.date = currentDate
        let calendar = Calendar.current
        let minDate = calendar.date(byAdding: .year, value: -1, to: currentDate)
        let maxDate = calendar.date(byAdding: .year, value: 1, to: currentDate)
        datePicker.minimumDate = minDate
        datePicker.maximumDate = maxDate
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter
    }()
    
    private lazy var trackersCollectionView: UICollectionView = {
        let layout = createCollectionViewLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TrackersCollectionViewCell.self,
                                forCellWithReuseIdentifier: TrackersCollectionViewCell.reuseIdentifier
        )
        collectionView.register(SupplementaryView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SupplementaryView.reuseHeaderIdentifier
        )
        return collectionView
    }()
    
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    private var currentDate = Date()
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //setupTestData()
        setupNavBar()
        setupViews()
        
        trackersCollectionView.dataSource = self
        trackersCollectionView.delegate = self
        
        refreshUIForSelectedDate()
    }
    
    // MARK: - Private Methods
    private func createDefaultTrackers() -> [Tracker] {
        return [
            Tracker(
                id: UUID(),
                title: "Зарядка утром",
                color: .systemGreen,
                emoji: "🏋️‍♀️",
                timeTable: [.monday, .wednesday, .thursday, .friday]
            ),
            Tracker(
                id: UUID(),
                title: "Поливать цветы",
                color: .systemPink,
                emoji: "🌸",
                timeTable: [.monday, .friday]
            ),
            Tracker(
                id: UUID(),
                title: "Кормить кота",
                color: .systemOrange,
                emoji: "🐈‍⬛",
                timeTable: [.monday, .wednesday, .friday]
            )
        ]
    }
    
    private func setupTestData() {
        categories = [TrackerCategory(title: "Важное", trackers: createDefaultTrackers())]
        refreshUIForSelectedDate()
    }
    
    @objc private func addTrackerButtonTapped() {
        let newHabitVC = NewHabitViewController()
        newHabitVC.delegate = self
        let navHabitVC = UINavigationController(rootViewController: newHabitVC)
        navHabitVC.modalPresentationStyle = .pageSheet
        present(navHabitVC, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        currentDate = selectedDate
        
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Выбранная дата 📅: \(formattedDate)")
        
        refreshUIForSelectedDate()
    }
    
    private func addNewTracker(tracker newTracker: Tracker, categoryName newCategoryTitle: String) {
        let newCategory = TrackerCategory(title: newCategoryTitle, trackers: [newTracker])
        var newCategories: [TrackerCategory] = []
        
        if !categories.isEmpty {
            newCategories = categories.map { category in
                if category.title == newCategoryTitle {
                    return TrackerCategory(title: category.title, trackers: category.trackers + [newTracker])
                }
                return category
            }
        } else {
            newCategories = [newCategory]
        }
        
        categories = newCategories
        
        print("Категории после добавления: \(categories.count) категорий")
        for category in categories {
            print("Категория: \(category.title), трекеров: \(category.trackers.count)")
        }
        
        refreshUIForSelectedDate()
    }
    
    private func getVisibleCategories() -> [TrackerCategory] {
        guard !categories.isEmpty else { return [] }
        
        let calendar = Calendar.current
        guard let weekday = calendar.dateComponents([.weekday], from: currentDate).weekday else { return [] }
        
        var filteredCategories: [TrackerCategory] = []
        
        for category in categories {
            let filteredTrackers = category.trackers.filter { tracker in
                tracker.timeTable.contains { day in
                    day.calendarWeekDay == weekday
                }
            }
            if !filteredTrackers.isEmpty {
                filteredCategories.append(TrackerCategory(title: category.title, trackers: filteredTrackers))
            }
        }
        return filteredCategories
    }
    
    private func updateVisibleCategories() {
        visibleCategories = getVisibleCategories()
    }
    
    private func updateUI() {
        placeholderView.isHidden = !visibleCategories.isEmpty
        trackersCollectionView.isHidden = visibleCategories.isEmpty
        trackersCollectionView.reloadData()
    }
    
    private func refreshUIForSelectedDate() {
        updateVisibleCategories()
        updateUI()
    }
    
    // MARK: - Private Methods(UI)
    private func setupViews() {
        view.addSubview(placeholderView)
        view.addSubview(trackersCollectionView)
        
        NSLayoutConstraint.activate([
            trackersCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupNavBar() {
        let plusButton = UIButton(type: .system)
        plusButton.setImage(.addTracker, for: .normal)
        plusButton.addTarget(self, action: #selector(addTrackerButtonTapped), for: .touchUpInside)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.widthAnchor.constraint(equalToConstant: 42).isActive = true
        plusButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        
        let datePickerButton = UIBarButtonItem(customView: datePicker)
        if #available(iOS 26.0, *) { datePickerButton.hidesSharedBackground = true }
        
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.hidesNavigationBarDuringPresentation = false
        search.automaticallyShowsCancelButton = true
        search.searchBar.placeholder = "Поиск"
        navigationItem.searchController = search
        definesPresentationContext = true
        search.searchBar.delegate = self
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: plusButton)
        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItem = datePickerButton
        navigationController?.navigationBar.tintColor = .blackDay
    }
    
    private func createCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .absolute(148)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(148)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                repeatingSubitem: item,
                count: 2
            )
            group.interItemSpacing = .fixed(8)
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 0
            
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(30)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]
            
            if #available(iOS 26.0, *) {
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: 16,
                    bottom: 16,
                    trailing: 16
                )
            } else {
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: 20,
                    bottom: 16,
                    trailing: 20
                )
            }
            
            return section
        }
        return layout
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section < categories.count else { return 0 }
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCollectionViewCell.reuseIdentifier,
                                                            for: indexPath) as? TrackersCollectionViewCell,
            indexPath.section < visibleCategories.count,
            indexPath.item < visibleCategories[indexPath.section].trackers.count
        else {
            return UICollectionViewCell()
        }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        cell.delegate = self
        //cell.setup передать все данные для ячейки
        cell.setupCell(tracker: tracker)
        cell.setupSelectedDate(date: currentDate)
        cell.backgroundColor = .clear
        return cell
        //3 шага: создание, передача данных и вернул ячейку
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = SupplementaryView.reuseHeaderIdentifier
        case UICollectionView.elementKindSectionFooter:
            id = "footer"
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

extension TrackersViewController: TrackerCellDelegate {
    func didAddCompletion(for tracker: Tracker, on date: Date) {
        let completedTracker = TrackerRecord(id: tracker.id, date: date)
        completedTrackers.insert(completedTracker)
        print("Трекер \(tracker.title) сохранен")
        print("Список выполненных трекеров: \(completedTrackers)")
    }
    func removeAddCompletion(for tracker: Tracker, on date: Date) {
        let completedTracker = TrackerRecord(id: tracker.id, date: date)
        completedTrackers.remove(completedTracker)
        print("Трекер \(tracker.title) удален")
        print("Список выполненных трекеров ниже:")
        for tracker in completedTrackers {
            print("Id: \(tracker.id) date: \(tracker.date)")
        }
        
    }
}

extension TrackersViewController: NewHabitViewControllerDelegate {
    func didCreateTracker(_ tracker: Tracker, categoryName: String) {
        //дернуть функцию для сохранения полученного трекере в основной контроллер
        print("Пришел новый трекер \(tracker.title) и категория \(categoryName)")
        addNewTracker(tracker: tracker, categoryName: categoryName)
    }
}

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        //TODO: реакция на изменения в поисковой строке
    }
}

extension TrackersViewController: UISearchBarDelegate {
    //TODO: обработка события (начало/завершение поиска и т. д.)
}

//#Preview {
//    return TabBarController()
//}
