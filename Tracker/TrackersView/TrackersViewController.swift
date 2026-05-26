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
        label.textColor = .appBlack
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
    
    private var pinnedTrackers: Set<UUID> = []
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    private var currentDate = Date()
    private var currentWeekday: Int {Calendar.current.component(.weekday, from: currentDate) }
    
    private let store: TrackerStoreProtocol
    private let recordStore: RecordStoreProtocol
    
    // MARK: - Initialisers
    init(store: TrackerStoreProtocol, recordStore: RecordStoreProtocol) {
        self.store = store
        self.recordStore = recordStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //setupTestData() трекеры для примера
        setupNavBar()
        loadInitialData()
        setupViews()
        
        trackersCollectionView.dataSource = self
        trackersCollectionView.delegate = self
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
        print("🔥 Начинаем сохранение трекера: \(newTracker.title)")
        do {
            try store.addTracker(newTracker, toCategory: newCategoryTitle)
            print("✅ Трекер сохранен: \(newTracker.title)")
            loadInitialData()
        } catch {
            print("❌ Ошибка сохранения трекера: \(error)")
        }
    }
    
    private func getTrackersForToday(in category: TrackerCategory) -> [Tracker] {
        let weekday = Calendar.current.component(.weekday, from: currentDate)
        return category.trackers.filter { $0.timeTable.contains { $0.calendarWeekDay == weekday } }
    }
    
    private func getVisibleCategories() -> [TrackerCategory] {
//        guard !categories.isEmpty else { return [] }
//        
//        var filteredCategories: [TrackerCategory] = []
//        
//        for category in categories {
//            let filteredTrackers = getTrackersForToday(in: category)
//            if !filteredTrackers.isEmpty {
//                filteredCategories.append(TrackerCategory(title: category.title, trackers: filteredTrackers))
//            }
//        }
//        return filteredCategories
        
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: currentDate)
        
        print("📅 Фильтрация для дня недели: \(weekday)")
        
        // Сначала собираем все трекеры на сегодня
        var allTodayTrackers: [Tracker] = []
        for category in categories {
            let trackersForToday = category.trackers.filter { tracker in
                tracker.timeTable.contains { $0.calendarWeekDay == weekday }
            }
            allTodayTrackers.append(contentsOf: trackersForToday)
        }
        
        // Разделяем на закрепленные и обычные
        let pinned = allTodayTrackers.filter { pinnedTrackers.contains($0.id) }
        let regular = allTodayTrackers.filter { !pinnedTrackers.contains($0.id) }
        
        // Группируем обычные по категориям
        var regularCategories: [TrackerCategory] = []
        for category in categories {
            let trackersInCategory = regular.filter { tracker in
                // Находим оригинальную категорию трекера
                category.trackers.contains { $0.id == tracker.id }
            }
            if !trackersInCategory.isEmpty {
                regularCategories.append(TrackerCategory(
                    title: category.title,
                    trackers: trackersInCategory
                ))
            }
        }
        
        // Формируем результат: сначала закрепленные, потом остальные категории
        var result: [TrackerCategory] = []
        if !pinned.isEmpty {
            result.append(TrackerCategory(title: "Закрепленные", trackers: pinned))
        }
        result.append(contentsOf: regularCategories)
        
        return result
    }
    
    private func updateVisibleCategories() {
        visibleCategories = getVisibleCategories()
    }
    
    private func isCompleted(trackerId: UUID, on date: Date) -> Bool {
        let targetDay = Calendar.current.startOfDay(for: date)
        return completedTrackers.contains { trackerRecord in
            trackerRecord.id == trackerId && Calendar.current.isDate(trackerRecord.date, inSameDayAs: targetDay)
        }
    }
    
    private func isFutureDate(_ date: Date) -> Bool {
        let todayStart = Calendar.current.startOfDay(for: Date())
        let selectedDateStart = Calendar.current.startOfDay(for: date)
        return selectedDateStart > todayStart
    }
    
    private func getSectionHeaderTitle(for section: Int) -> String {
        let visibleCategories = getVisibleCategories()
        guard section < visibleCategories.count else { return "" }
        return visibleCategories[section].title
    }
    
    // MARK: - CoreData
    private func loadInitialData() {
        do {
            categories = try store.fetchAllCategories()
            completedTrackers = Set(try recordStore.fetchAllRecords())
            
            if let pinnedIds = try? store.fetchAllPinnedTrackerIds() {
                pinnedTrackers = Set(pinnedIds)
            }
            
            visibleCategories = categories
            refreshUIForSelectedDate()
        } catch {
            print("Ошибка загрузки данных: \(error)")
        }
    }
    
    // MARK: - Private Methods(UI)
    private func updateUI() {
        placeholderView.isHidden = !visibleCategories.isEmpty
        print("📱 placeholder скрыт: \(!visibleCategories.isEmpty)")
        trackersCollectionView.isHidden = visibleCategories.isEmpty
        trackersCollectionView.reloadData()
    }
    
    private func refreshUIForSelectedDate() {
        updateVisibleCategories()
        updateUI()
    }
    
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
        navigationController?.navigationBar.tintColor = .appBlack
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
        return getVisibleCategories().count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let visibleCategories = getVisibleCategories()
        guard section < visibleCategories.count else { return 0 }
        
        let category = visibleCategories[section]
        let trackersForToday = getTrackersForToday(in: category)
        return trackersForToday.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCollectionViewCell.reuseIdentifier,
                                                          for: indexPath) as? TrackersCollectionViewCell
        else { return UICollectionViewCell() }
        
        cell.delegate = self
        
        let visibleCategories = getVisibleCategories()
        guard indexPath.section < visibleCategories.count,
              indexPath.item < visibleCategories[indexPath.section].trackers.count else { return cell }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        
        let isPinned = pinnedTrackers.contains(tracker.id)
        print("📍 Трекер '\(tracker.title)', isPinned: \(isPinned)")
        
        if let cell = collectionView.cellForItem(at: indexPath) as? TrackersCollectionViewCell {
            let newCount = (try? self.recordStore.countRecords(for: tracker.id)) ?? 0
            cell.updateCounter(newCount)
        }
        
        let completionCount = (try? recordStore.countRecords(for: tracker.id)) ?? 0
        
        let isCompleted = self.isCompleted(trackerId: tracker.id, on: currentDate)
        
        let isFuture = isFutureDate(currentDate)
        cell.isUserInteractionEnabled = !isFuture
        cell.contentView.alpha = isFuture ? 0.5 : 1
        cell.isUserInteractionEnabled = !isFuture
        
        cell.configure(with: tracker,
                       isPinned: isPinned,
                       isCompleted: isCompleted,
                       isFutureDate: isFuture,
                       numbersOfCompletedTrackers: completionCount
        )
        cell.backgroundColor = .clear
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = SupplementaryView.reuseHeaderIdentifier
        case UICollectionView.elementKindSectionFooter:
            id = "footer"
        default:
            assertionFailure("Unsupported supplementary view kind: \(kind)")
            return UICollectionReusableView()
        }
        
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? SupplementaryView else {
            assertionFailure("Failed to dequeue supplementary view of kind: \(kind) with identifier: \(id)")
            return UICollectionReusableView()
        }
        let categoryTitle = getSectionHeaderTitle(for: indexPath.section)
        header.setupHeader(title: categoryTitle)
        return header
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
    func addOrRemoveCompletionTracker(for tracker: Tracker, isCompletedInCell: Bool) {
        print("🔘 Нажатие на трекер '\(tracker.title)")
        let today = Calendar.current.startOfDay(for: self.currentDate)
        
        do {
            if isCompletedInCell {
                print("   ➕ Добавляем запись в Core Data")
                try self.recordStore.addRecord(trackerId: tracker.id, date: today)
            } else {
                print("   ➖ Удаляем запись из Core Data")
                try self.recordStore.removeRecord(trackerId: tracker.id, date: today)
            }
            
            self.completedTrackers = Set(try self.recordStore.fetchAllRecords())
            print("📊 completedTrackers после обновления: \(self.completedTrackers.count)")
            
            trackersCollectionView.reloadData()
        } catch {
            print("❌ Ошибка: \(error)")
        }
    }
}

extension TrackersViewController: NewHabitViewControllerDelegate {
    func didCreateTracker(_ tracker: Tracker, categoryName: String) {
        addNewTracker(tracker: tracker, categoryName: categoryName)
    }
    
    func didUpdateTracker(_ tracker: Tracker, category: String) {
        updateTracker(tracker, category: category)
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

// MARK: - Действия с ячейкой
extension TrackersViewController {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard let indexPath = indexPaths.first else { return nil }
        
        let visibleCategories = getVisibleCategories()
        guard indexPath.section < visibleCategories.count,
              indexPath.item < visibleCategories[indexPath.section].trackers.count else {
            return nil
        }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        let isPinned = pinnedTrackers.contains(tracker.id)
        
        return UIContextMenuConfiguration(actionProvider: { _ in
            
            // 👇 Пункт "Закрепить/Открепить"
            let pinTitle = isPinned ? "Открепить" : "Закрепить"
            let pinImage = isPinned ? "pin.slash" : "pin"
            
            let pinAction = UIAction(
                title: pinTitle,
                image: UIImage(systemName: pinImage)
            ) { [weak self] _ in
                self?.togglePin(for: tracker)
            }
            
            // 👇 Пункт "Редактировать"
            let editAction = UIAction(
                title: "Редактировать",
                image: UIImage(systemName: "pencil")
            ) { [weak self] _ in
                self?.editTracker(tracker)
            }
            
            // 👇 Пункт "Удалить"
            let deleteAction = UIAction(
                title: "Удалить",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self] _ in
                self?.showDeleteConfirmation(for: tracker)
            }
            
            return UIMenu(children: [pinAction, editAction, deleteAction])
        })
    }
    
    private func togglePin(for tracker: Tracker) {
        do {
            try store.togglePin(for: tracker.id)
            
            // Обновляем локальный кэш
            if pinnedTrackers.contains(tracker.id) {
                pinnedTrackers.remove(tracker.id)
            } else {
                pinnedTrackers.insert(tracker.id)
            }
            
            // Перезагружаем данные для отображения в правильном порядке
            loadInitialData()
            
        } catch {
            print("❌ Ошибка при закреплении: \(error)")
            showErrorAlert("Не удалось изменить статус закрепления")
        }
    }
    
    private func editTracker(_ tracker: Tracker) {
        print("✏️ Редактирование трекера: \(tracker.title)")
        print("📅 Расписание трекера: \(tracker.timeTable.map { $0.rawValue })") // 👈 Отладка
        
        let completedDaysCount = (try? recordStore.countRecords(for: tracker.id)) ?? 0
        print("📊 Количество выполненных дней: \(completedDaysCount)")
        
        guard let _ = try? store.fetchCategoryForTracker(trackerId: tracker.id) else {
            print("❌ Не удалось получить категорию трекера")
            return
        }
        
        let editVC = NewHabitViewController(
            mode: .edit(tracker),
            store: store,
            completedDaysCount: completedDaysCount
        )
        editVC.delegate = self
        
        let navController = UINavigationController(rootViewController: editVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
    
    private func updateTracker(_ tracker: Tracker, category: String) {
        do {
            try store.updateTracker(newTracker: tracker, categoryTitle: category)
            loadInitialData()
            print(" Успешное обновление трекера")
        } catch {
            print("❌ Ошибка при обновлении: \(error)")
            showErrorAlert("Не удалось обновить трекер")
        }
    }
    
    private func showDeleteConfirmation(for tracker: Tracker) {
        let alert = UIAlertController(
            title: "Удалить трекер?",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.deleteTracker(tracker)
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func deleteTracker(_ tracker: Tracker) {
        do {
            try store.deleteTracker(id: tracker.id)
            loadInitialData()
        } catch {
            print("❌ Ошибка при удалении: \(error)")
            showErrorAlert("Не удалось удалить трекер")
        }
    }
    
    private func showErrorAlert(_ message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

//#Preview {
//    return TabBarController()
//}
