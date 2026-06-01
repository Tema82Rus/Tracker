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
        label.text = NSLocalizedString("trackers.placeholder.title", comment: "Placeholder text when no trackers")
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
        datePicker.locale = Locale.current
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
    
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("trackers.filter.button", comment: "Filters button"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var emptyFilterPlaceholderView: UIView = {
        
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let starImage = UIImageView(image: UIImage(resource: .appErrorSearch))
        starImage.tintColor = .appGray
        starImage.contentMode = .scaleAspectFit
        starImage.widthAnchor.constraint(equalToConstant: 80).isActive = true
        starImage.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        let labelTextError = UILabel()
        labelTextError.translatesAutoresizingMaskIntoConstraints = false
        labelTextError.text = NSLocalizedString("trackers.empty_filter.title", comment: "Empty filter state text")
        labelTextError.numberOfLines = 1
        labelTextError.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        labelTextError.textColor = .appBlack
        labelTextError.textAlignment = .center
        labelTextError.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        labelTextError.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let textSize = labelTextError.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 20))
        labelTextError.widthAnchor.constraint(greaterThanOrEqualToConstant: textSize.width).isActive = true
        
        stack.addArrangedSubview(starImage)
        stack.addArrangedSubview(labelTextError)
        
        container.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -16)
        ])
        return container
    }()
    
    private var isSearchActive: Bool {
        return navigationItem.searchController?.isActive ?? false &&
        !(navigationItem.searchController?.searchBar.text?.isEmpty ?? true)
    }
    
    private var pinnedTrackers: Set<UUID> = []
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    private var currentDate = Date()
    private var currentWeekday: Int {Calendar.current.component(.weekday, from: currentDate) }
    
    private var currentFilter: TrackerFilter = .all {
        didSet {
            saveFilterState()
            updateFilterButtonAppearance()
            applyFilter()
        }
    }
    
    private let store: TrackerStoreProtocol
    private let recordStore: RecordStoreProtocol
    private let searchService = SearchService()
    
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
        loadFilterState()
        searchService.delegate = self
        setupNavBar()
        setupSearchService()
        
        loadInitialData()
        setupViews()
        
        trackersCollectionView.dataSource = self
        trackersCollectionView.delegate = self
        
        AnalyticsService.report(
            event: .open,
            params: [
                .screen: .main
            ]
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AnalyticsService.report(event: .close, params: [.screen: .main])
    }
    
    // MARK: - Selector Methods
    @objc private func addTrackerButtonTapped() {
        AnalyticsService.report(
            event: .click,
            params: [
                .screen: .main,
                .item: .add_track
            ]
        )
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
        
        if !isSearchActive {
            visibleCategories = getVisibleCategories()
            trackersCollectionView.reloadData()
            updatePlaceholderVisibility()
        } else {
            trackersCollectionView.reloadData()
        }
        
        updatePlaceholderVisibility()
    }
    
    @objc private func filterButtonTapped() {
        AnalyticsService.report(
            event: .click,
            params: [
                .screen: .main,
                    .item: .filter
            ]
        )
        let filterVC = FilterViewController(currentFilter: currentFilter)
        filterVC.delegate = self
        
        let navController = UINavigationController(rootViewController: filterVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
    
    // MARK: - Private Methods
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
        if isSearchActive {
            /// При поиске используем уже отфильтрованные visibleCategories
            return visibleCategories
        }
        
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
        
        var filteredTrackers: [Tracker] = []
        
        switch currentFilter {
        case .all, .today:
            filteredTrackers = allTodayTrackers
        case .completed:
            filteredTrackers = allTodayTrackers.filter { tracker in
                isCompleted(trackerId: tracker.id, on: currentDate)
            }
        case .uncompleted:
            filteredTrackers = allTodayTrackers.filter { tracker in
                !isCompleted(trackerId: tracker.id, on: currentDate)
            }
        }
        return groupTrackersByCategory(trackers: filteredTrackers)
    }
    
    private func groupTrackersByCategory(trackers: [Tracker]) -> [TrackerCategory] {
        let pinned = trackers.filter { pinnedTrackers.contains($0.id) }
        let regular = trackers.filter { !pinnedTrackers.contains($0.id) }
        
        var regularCategories: [TrackerCategory] = []
        for category in categories {
            let trackersInCategory = regular.filter { tracker in
                category.trackers.contains { $0.id == tracker.id }
            }
            if !trackersInCategory.isEmpty {
                regularCategories.append(TrackerCategory(title: category.title, trackers: trackersInCategory))
            }
        }
        
        var result: [TrackerCategory] = []
        if !pinned.isEmpty {
            result.append(TrackerCategory(title: NSLocalizedString("pinned.section", comment: ""), trackers: pinned))
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
    
    private func setupSearchService() {
        searchService.updateCategories(categories)
    }
    
    // MARK: - Filter Methods
    private func applyFilter() {
        print("🔄 Применение фильтра: \(currentFilter.title)")
        
        updateVisibleCategories()
        
        DispatchQueue.main.async {
            self.trackersCollectionView.reloadData()
            self.updatePlaceholderVisibility()
            self.updateFilterButtonVisibility()
        }
    }
    
    private func updateFilterButtonVisibility() {
        let hasAnyTrackersInDB = !categories.flatMap { $0.trackers }.isEmpty
        filterButton.isHidden = !hasAnyTrackersInDB
    }
    
    private func updateFilterButtonAppearance() {
        filterButton.backgroundColor = currentFilter.isStrictFilter ? .systemRed : .systemBlue
    }
    
    private func saveFilterState() {
        UserDefaults.standard.set(currentFilter.rawValue, forKey: "SelectedTrackerFilter")
    }

    private func loadFilterState() {
        let rawValue = UserDefaults.standard.integer(forKey: "SelectedTrackerFilter")
        currentFilter = TrackerFilter(rawValue: rawValue) ?? .all
    }
    
    // MARK: - CoreData
    private func loadInitialData() {
        do {
            categories = try store.fetchAllCategories()
            completedTrackers = Set(try recordStore.fetchAllRecords())
            
            if let pinnedIds = try? store.fetchAllPinnedTrackerIds() {
                pinnedTrackers = Set(pinnedIds)
            }
            searchService.updateCategories(categories)
            
            if !isSearchActive {
                visibleCategories = getVisibleCategories()
            }
            
            trackersCollectionView.reloadData()
            updatePlaceholderVisibility()
            updateFilterButtonVisibility()
            
        } catch {
            print("Ошибка загрузки данных: \(error)")
        }
    }
    
    // MARK: - Private Methods(UI)
    private func updatePlaceholderVisibility() {
        let hasAnyTrackersInDB = !categories.flatMap { $0.trackers }.isEmpty
        let weekday = Calendar.current.component(.weekday, from: currentDate)
        
        /// Считаем трекеры на выбранный день из исходных данных
        var trackersCountForDay = 0
        for category in categories {
            trackersCountForDay += category.trackers.filter {
                $0.timeTable.contains { $0.calendarWeekDay == weekday }
            }.count
        }
        let hasTrackersForSelectedDay = trackersCountForDay > 0

        /// Считаем видимые трекеры в текущем состоянии (с учётом фильтра и поиска)
        let totalVisibleTrackers = visibleCategories.reduce(0) { $0 + $1.trackers.count }
        let hasVisibleTrackers = totalVisibleTrackers > 0

        /// 🔑 Чёткое разделение сценариев:
        let shouldShowMainPlaceholder: Bool
        let shouldShowFilterPlaceholder: Bool

        if isSearchActive {
            /// При активном поиске:
            /// - если visibleCategories пуст → показываем emptyFilterPlaceholderView
            /// - в остальных случаях скрываем оба placeholder'а (данные есть)
            shouldShowMainPlaceholder = false
            shouldShowFilterPlaceholder = visibleCategories.isEmpty
        } else {
            /// В обычном режиме (без поиска):
            /// - main placeholder: нет трекеров в БД ИЛИ нет трекеров на день
            /// - filter placeholder: есть трекеры на день, но фильтр их скрыл
            shouldShowMainPlaceholder = !hasAnyTrackersInDB || !hasTrackersForSelectedDay
            shouldShowFilterPlaceholder = hasTrackersForSelectedDay &&
                                       currentFilter.isStrictFilter &&
                                       !hasVisibleTrackers
        }

        placeholderView.isHidden = !shouldShowMainPlaceholder
        emptyFilterPlaceholderView.isHidden = !shouldShowFilterPlaceholder
        filterButton.isHidden = !hasTrackersForSelectedDay
    }

    private func setupViews() {
        view.backgroundColor = .appWhite
        view.addSubview(placeholderView)
        view.addSubview(trackersCollectionView)
        view.addSubview(emptyFilterPlaceholderView)
        view.addSubview(filterButton)
        
        trackersCollectionView.contentInsetAdjustmentBehavior = .never
        
        NSLayoutConstraint.activate([
            trackersCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyFilterPlaceholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyFilterPlaceholderView.centerYAnchor.constraint(equalTo: trackersCollectionView.centerYAnchor),
            
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 114),
        ])
        
        trackersCollectionView.verticalScrollIndicatorInsets.bottom = 60
        trackersCollectionView.contentInset.bottom = 80
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
        search.searchBar.placeholder = NSLocalizedString("trackers.search.placeholder", comment: "Search placeholder")
        navigationItem.searchController = search
        definesPresentationContext = true
        search.searchBar.delegate = self
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: plusButton)
        navigationItem.title = NSLocalizedString("trackers.title", comment: "Title for trackers screen")
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
        guard section < visibleCategories.count else { return 0 }
        let category = visibleCategories[section]
        return category.trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCollectionViewCell.reuseIdentifier,
                                                          for: indexPath) as? TrackersCollectionViewCell
        else { return UICollectionViewCell() }
        
        cell.delegate = self
        
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
        header.setupHeader(title: getVisibleCategories()[indexPath.section].title)
        return header
    }
}


// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let header = SupplementaryView(frame: .zero)
        return header.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                     height: UIView.layoutFittingCompressedSize.height)
        )
    }
}

// MARK: - TrackerCellDelegate
extension TrackersViewController: TrackerCellDelegate {
    func addOrRemoveCompletionTracker(for tracker: Tracker, isCompletedInCell: Bool) {
        AnalyticsService.report(
            event: .click,
            params: [
                .screen: .main,
                    .item: .track
            ]
        )
        
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
            if self.currentFilter.isStrictFilter {
                self.applyFilter()
            } else {
                trackersCollectionView.reloadData()
            }
        } catch {
            print("❌ Ошибка: \(error)")
        }
    }
}

// MARK: - NewHabitViewControllerDelegate
extension TrackersViewController: NewHabitViewControllerDelegate {
    func didCreateTracker(_ tracker: Tracker, categoryName: String) {
        addNewTracker(tracker: tracker, categoryName: categoryName)
    }
    
    func didUpdateTracker(_ tracker: Tracker, category: String) {
        updateTracker(tracker, category: category)
    }
}

// MARK: - UISearchResultsUpdating
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        print("🔍 ПОИСК: Введен текст '\(searchText)'")
        
        if searchText.isEmpty {
            print("🔍 ПОИСК: Текст пуст, сброс")
            
            visibleCategories = categories
            trackersCollectionView.reloadData()
        } else {
            print("🔍 ПОИСК: Запуск фильтрации")
            
            searchService.filterCategories(searchText: searchText)
        }
    }
}

// MARK: - SearchServiceDelegate
extension TrackersViewController: SearchServiceDelegate {
    func didUpdateSearchResults(_ filteredCategories: [TrackerCategory]) {
        DispatchQueue.main.async {
            print("🔎 Search results: \(filteredCategories.count) categories")
            self.visibleCategories = filteredCategories
            print("🔎 visibleCategories updated: \(self.visibleCategories.count)")
            self.trackersCollectionView.reloadData()
            self.updatePlaceholderVisibility()
        }
    }
}

// MARK: - FilterViewControllerDelegate
extension TrackersViewController: FilterViewControllerDelegate {
    func didSelectFilter(_ filter: TrackerFilter) {
        
        print("🎛 Выбран фильтр: \(filter.title)")
        
        if filter == .today {
            currentDate = Date()
            datePicker.date = Date()
        }
        currentFilter = filter
        applyFilter()
    }
    
}

// MARK: - UISearchBarDelegate
extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchService.filterCategories(searchText: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        visibleCategories = categories
        trackersCollectionView.reloadData()
        updatePlaceholderVisibility()
        searchBar.resignFirstResponder()
    }
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
            let pinTitle = isPinned
            ? NSLocalizedString("tracker.unpin", comment: "Unpin tracker")
            : NSLocalizedString("tracker.pin", comment: "Pin tracker")
            let pinImage = isPinned ? "pin.slash" : "pin"
            
            let pinAction = UIAction(
                title: pinTitle,
                image: UIImage(systemName: pinImage)
            ) { [weak self] _ in
                self?.togglePin(for: tracker)
            }
            
            // 👇 Пункт "Редактировать"
            let editAction = UIAction(
                title: NSLocalizedString("common.edit", comment: "Edit"),
                image: UIImage(systemName: "pencil")
            ) { [weak self] _ in
                AnalyticsService.report(
                    event: .click,
                    params: [
                        .screen: .main,
                        .item: .edit
                    ]
                )
                
                self?.editTracker(tracker)
            }
            
            // 👇 Пункт "Удалить"
            let deleteAction = UIAction(
                title: NSLocalizedString("common.delete", comment: "Delete"),
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self] _ in
                AnalyticsService.report(
                    event: .click,
                    params: [
                        .screen: .main,
                        .item: .delete
                    ]
                )
                
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
            showErrorAlert(NSLocalizedString("error.pin", comment: "Pin error message"))
        }
    }
    
    private func editTracker(_ tracker: Tracker) {
        print("✏️ Редактирование трекера: \(tracker.title)")
        print("📅 Расписание трекера: \(tracker.timeTable.map { $0.rawValue })")
        
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
            showErrorAlert(NSLocalizedString("error.update", comment: "Update error message"))
        }
    }
    
    private func showDeleteConfirmation(for tracker: Tracker) {
        let alert = UIAlertController(
            title: NSLocalizedString("delete.title", comment: "Delete confirmation title"),
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(
            title: NSLocalizedString("common.delete", comment: "Delete"),
            style: .destructive
        ) { [weak self] _ in
            self?.deleteTracker(tracker)
        }
        
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("common.cancel", comment: "Cancel"),
            style: .cancel
        )
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func deleteTracker(_ tracker: Tracker) {
        do {
            try store.deleteTracker(id: tracker.id)
            NotificationCenter.default.post(name: .trackerRecordsDidUpdate, object: nil)
            loadInitialData()
        } catch {
            print("❌ Ошибка при удалении: \(error)")
            showErrorAlert(NSLocalizedString("error.delete", comment: "Delete error message"))
        }
    }
    
    private func showErrorAlert(_ message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("common.ok", comment: "OK"),
            style: .default)
        )
        present(alert, animated: true)
    }
}

//#Preview {
//    return TabBarController()
//}
