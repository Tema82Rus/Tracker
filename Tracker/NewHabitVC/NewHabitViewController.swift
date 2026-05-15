//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by Artem Yaroshenko on 06.05.2026.
//

import UIKit

protocol NewHabitViewControllerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, categoryName: String)
}

final class NewHabitViewController: UIViewController, UITextFieldDelegate {
    // MARK: Public Properties
    weak var delegate: NewHabitViewControllerDelegate?
    
    // MARK: Private Properties
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .appBlack
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .backgroundDay
        textField.borderStyle = .none
        textField.layer.cornerRadius = 16
        textField.clipsToBounds = true
        textField.placeholder = "Введите название трекера"
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    private lazy var keyboardToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        let cancel = UIBarButtonItem(
            title: "Отмена",
            style: .plain,
            target: self,
            action: #selector(dismissKeyboard)
        )
        let save = UIBarButtonItem(
            title: "Сохранить",
            style: .done,
            target: self,
            action: #selector(saveButtonTappedKeyboard)
        )
        toolbar.items = [cancel, flexibleSpace, save]
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            toolbar.heightAnchor.constraint(equalToConstant: 75)
        ])
        
        return toolbar
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .appRed
        label.textAlignment = .center
        label.sizeToFit()
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var categoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.backgroundColor = .clear
        button.setTitle("Категория", for: .normal)
        button.setTitleColor(.appBlack, for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 32)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addTapCategory), for: .touchUpInside)
        
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .appGray
        chevron.contentMode = .center
        chevron.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(chevron)
        
        NSLayoutConstraint.activate([
            chevron.widthAnchor.constraint(equalToConstant: 7),
            chevron.heightAnchor.constraint(equalToConstant: 12),
            chevron.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -24),
            chevron.centerYAnchor.constraint(equalTo: button.titleLabel!.centerYAnchor)
        ])
        
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return button
    }()
    
    private lazy var scheduleButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.backgroundColor = .clear
        button.setTitle("Расписание", for: .normal)
        button.setTitleColor(.appBlack, for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 32)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addTapSchedule), for: .touchUpInside)
        
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .appGray
        chevron.contentMode = .center
        chevron.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(chevron)
        
        NSLayoutConstraint.activate([
            chevron.widthAnchor.constraint(equalToConstant: 7),
            chevron.heightAnchor.constraint(equalToConstant: 12),
            chevron.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -24),
            chevron.centerYAnchor.constraint(equalTo: button.titleLabel!.centerYAnchor)
        ])
        
        button.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return button
    }()
    
    private lazy var dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .appGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var backgroundBlockView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundDay
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var emojiAndColorCollectionView: UICollectionView = {
        let layout = createCollectionViewCompositionalLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.dataSource = self
        collection.delegate = self
        collection.allowsSelection = true
        collection.isScrollEnabled = false
        
        collection.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.reuseIdentifier)
        collection.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.reuseIdentifier)
        collection.register(HeaderOfEmojiColor.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderOfEmojiColor.reuseIdentifier)
        
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.backgroundColor = .appGray
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.contentHorizontalAlignment = .center
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .ypWhite
        button.layer.cornerRadius = 16
        button.layer.borderColor = UIColor.appRed.cgColor
        button.layer.borderWidth = 1.0
        button.clipsToBounds = true
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.appRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.contentHorizontalAlignment = .center
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var categoryButtonTopWhenErrorHidden: NSLayoutConstraint?
    private var categoryButtonTopWhenErrorVisible: NSLayoutConstraint?
    
    private var selectedCategory: String = "Важное"
    private var selectedSchedule: Set<WeekDay> = []
    private var scheduleDisplayText: String {
        if selectedSchedule.count == WeekDay.allCases.count {
            return "Каждый день"
        } else {
            let sortedDays = selectedSchedule.sorted { $0.calendarWeekDay < $1.calendarWeekDay }
            return sortedDays.map { $0.shortTitle }.joined(separator: ", ")
        }
    }
    
    private let emojis: [String] = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    private let colors: [UIColor] = [.appColorSelection1, .appColorSelection2, .appColorSelection3, .appColorSelection4, .appColorSelection5, .appColorSelection6, .appColorSelection7, .appColorSelection8, .appColorSelection9, .appColorSelection10, .appColorSelection11, .appColorSelection12, .appColorSelection13, .appColorSelection14, .appColorSelection15, .appColorSelection16, .appColorSelection17, .appColorSelection18]
    
    private var selectedEmojiIndex: Int? = nil
    private var selectedColorIndex: Int? = nil
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.titleView = titleLabel
        setupViews()
    }
    
    // MARK: Private Methods
    private func setupViews() {
        let stackBottomButton = UIStackView()
        stackBottomButton.axis = .horizontal
        stackBottomButton.spacing = 8
        stackBottomButton.distribution = .fillEqually
        stackBottomButton.translatesAutoresizingMaskIntoConstraints = false
        stackBottomButton.addArrangedSubview(cancelButton)
        stackBottomButton.addArrangedSubview(createButton)
        view.addSubview(stackBottomButton)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(textField)
        contentView.addSubview(errorLabel)
        contentView.addSubview(backgroundBlockView)
        contentView.addSubview(emojiAndColorCollectionView)
        
        backgroundBlockView.addSubview(categoryButton)
        backgroundBlockView.addSubview(scheduleButton)
        backgroundBlockView.addSubview(dividerView)
        
        textField.inputAccessoryView = keyboardToolbar
        
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = leftPaddingView
        textField.leftViewMode = .always
        
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.rightView = rightPaddingView
        textField.rightViewMode = .always
        
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            errorLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            backgroundBlockView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            backgroundBlockView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            backgroundBlockView.heightAnchor.constraint(equalToConstant: 150.5),
            scheduleButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.keyboardLayoutGuide.topAnchor, constant: -24),
            
            categoryButton.topAnchor.constraint(equalTo: backgroundBlockView.topAnchor),
            categoryButton.heightAnchor.constraint(equalToConstant: 75),
            categoryButton.leadingAnchor.constraint(equalTo: backgroundBlockView.leadingAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: backgroundBlockView.trailingAnchor),
            
            dividerView.topAnchor.constraint(equalTo: categoryButton.bottomAnchor),
            dividerView.leadingAnchor.constraint(equalTo: categoryButton.leadingAnchor, constant: 16),
            dividerView.trailingAnchor.constraint(equalTo: categoryButton.trailingAnchor, constant: -16),
            dividerView.heightAnchor.constraint(equalToConstant: 0.5),
            
            scheduleButton.topAnchor.constraint(equalTo: dividerView.bottomAnchor),
            scheduleButton.leadingAnchor.constraint(equalTo: backgroundBlockView.leadingAnchor),
            scheduleButton.trailingAnchor.constraint(equalTo: backgroundBlockView.trailingAnchor),
            scheduleButton.heightAnchor.constraint(equalToConstant: 75),
            scheduleButton.bottomAnchor.constraint(equalTo: backgroundBlockView.bottomAnchor),
            
            emojiAndColorCollectionView.topAnchor.constraint(equalTo: backgroundBlockView.bottomAnchor, constant: 32),
            emojiAndColorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiAndColorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiAndColorCollectionView.heightAnchor.constraint(equalToConstant: 550),
            emojiAndColorCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),
            
            stackBottomButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackBottomButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackBottomButton.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor),
            stackBottomButton.heightAnchor.constraint(equalToConstant: 60),
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: stackBottomButton.topAnchor, constant: -8),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo:  scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        let heightConstraint = contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor)
        heightConstraint.priority = .defaultLow
        heightConstraint.isActive = true
        
        categoryButtonTopWhenErrorHidden = categoryButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24)
        categoryButtonTopWhenErrorVisible = categoryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 32)
        
        categoryButtonTopWhenErrorHidden?.isActive = true
    }
    
    @objc private func textFieldDidChange() {
        guard let text = textField.text else { return }
        let isOverLimit = text.count >= 38
        errorLabel.isHidden = !isOverLimit
        
        categoryButtonTopWhenErrorHidden?.isActive = !isOverLimit
        categoryButtonTopWhenErrorVisible?.isActive = isOverLimit
    }
    
    @objc private func addTapCategory() {
        updateCategoryButtonTitle()
    }
    
    @objc private func addTapSchedule() {
        let newScheduleVC = ScheduleVC()
        newScheduleVC.onSave = { [weak self] days in
            guard let self else { return }
            self.selectedSchedule = Set(days)
            updateScheduleButtonTitle()
            conditionCreateButton()
        }
        navigationController?.pushViewController(newScheduleVC, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        textField.resignFirstResponder()
    }
    
    @objc private func saveButtonTappedKeyboard() {
        textField.resignFirstResponder()
    }
    
    @objc private func createButtonTapped() {
        guard let nameTracker = textField.text, !nameTracker.isEmpty,
                let emojiIndex = selectedEmojiIndex,
                let colorIndex = selectedColorIndex else { return }
        
        print("📦 NewHabitVC: создаем трекер с расписанием: \(selectedSchedule.map { $0.rawValue })")
        
        let category = selectedCategory
        
        let newTracker = Tracker(id: UUID(),
                                 title: nameTracker,
                                 color: colors[colorIndex],
                                 emoji: emojis[emojiIndex],
                                 timeTable: selectedSchedule
        )
        
        print("🚀 NewHabitVC: отправляем трекер в TrackersViewController")
        
        //let newCategoryTitle = selectedCategory
        delegate?.didCreateTracker(newTracker, categoryName: category)
        dismiss(animated: true)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    private func updateCategoryButtonTitle() {
        let titleText = selectedCategory
        
        let fullTest = "Категория\n\(titleText)"
        
        let attributed = NSMutableAttributedString(string: fullTest)
        
        let mainTitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .regular),
            .foregroundColor: UIColor.appBlack
        ]
        
        let categoryAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .regular),
            .foregroundColor: UIColor.appGray
        ]
        
        let titleWithNewline = "Категория\n"
        let mainTitleRange = NSRange(location: 0, length: titleWithNewline.utf16.count)
        
        let categoryRange = NSRange(location: mainTitleRange.length, length: titleText.utf16.count)
        
        attributed.setAttributes(mainTitleAttributes, range: mainTitleRange)
        attributed.setAttributes(categoryAttributes, range: categoryRange)
        
        DispatchQueue.main.async {
            self.categoryButton.titleLabel?.numberOfLines = 0
            self.categoryButton.titleLabel?.lineBreakMode = .byWordWrapping
            self.categoryButton.setAttributedTitle(attributed, for: .normal)
        }
        
    }
    
    private func updateScheduleButtonTitle() {
        let displayText = scheduleDisplayText
        let fullTest = "Расписание\n\(displayText)"
        let attributed = NSMutableAttributedString(string: fullTest)
        
        let mainTitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .regular),
            .foregroundColor: UIColor.appBlack
        ]
        
        let categoryAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .regular),
            .foregroundColor: UIColor.appGray
        ]
        
        let titleWithNewLine = "Расписание\n"
        let titleRange = NSRange(location: 0, length: titleWithNewLine.utf16.count)
        
        let daysRange = NSRange(location: titleRange.length, length: displayText.utf16.count)
        
        attributed.setAttributes(mainTitleAttributes, range: titleRange)
        attributed.setAttributes(categoryAttributes, range: daysRange)
        
        DispatchQueue.main.async {
            self.scheduleButton.titleLabel?.numberOfLines = 0
            self.scheduleButton.titleLabel?.lineBreakMode = .byWordWrapping
            self.scheduleButton.setAttributedTitle(attributed, for: .normal)
        }
    }
    
    private func conditionCreateButton() {
        let hasName = !(textField.text?.isEmpty ?? true)
        let hasSchedule = !selectedSchedule.isEmpty
        
        let hasEmoji = selectedEmojiIndex != nil
        let hasColor = selectedColorIndex != nil
        
        let isValid = hasName && hasSchedule && hasEmoji && hasColor
        
        createButton.isEnabled = isValid
        createButton.backgroundColor = isValid ? .appBlack : .appGray
    }
    
    // MARK: - CollectionView UI Configuration
    private func createCollectionViewCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            guard let section = Section(rawValue: sectionIndex) else {
                return nil
            }
            
            switch section {
            case .emoji: return self.createEmojiSection()
            case .color: return self.createColorSection()
            }
        }
        return layout
    }
    
    private func createEmojiSection() -> NSCollectionLayoutSection {
        createGridSection(
            numberOfItemsPerRow: 6,
            interItemSpacing: 5,
            sectionInsets: NSDirectionalEdgeInsets(top: 24, leading: 18, bottom: 24, trailing: 18)
        )
    }
    
    private func createColorSection() -> NSCollectionLayoutSection {
        createGridSection(
            numberOfItemsPerRow: 6,
            interItemSpacing: 5,
            sectionInsets: NSDirectionalEdgeInsets(top: 24, leading: 18, bottom: 24, trailing: 18)
        )
    }
    
    private func createGridSection(
        numberOfItemsPerRow: Int,
        interItemSpacing: CGFloat,
        sectionInsets: NSDirectionalEdgeInsets
    ) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / CGFloat(numberOfItemsPerRow)),
                                              heightDimension: .fractionalWidth(1.0 / CGFloat(numberOfItemsPerRow))
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: interItemSpacing / 2,
            bottom: 0,
            trailing: interItemSpacing / 2
        )
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: itemSize.heightDimension
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: numberOfItemsPerRow
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = sectionInsets
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(40)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
}

extension NewHabitViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        switch section {
        case .emoji: return emojis.count
        case .color: return colors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }
        
        switch section {
        case .emoji:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmojiCell.reuseIdentifier,
                for: indexPath
            ) as? EmojiCell else { return UICollectionViewCell() }
            let isSelected = indexPath.item == selectedEmojiIndex
            cell.configure(with: emojis[indexPath.item], isSelected: isSelected)
            return cell
        case .color:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ColorCell.reuseIdentifier,
                for: indexPath
            ) as? ColorCell else { return UICollectionViewCell() }
            let isSelected = indexPath.item == selectedColorIndex
            cell.configure(with: colors[indexPath.item], isSelected: isSelected)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let section = Section(rawValue: indexPath.section)
        else {
            return UICollectionReusableView()
        }
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: HeaderOfEmojiColor.reuseIdentifier,
            for: indexPath
        ) as? HeaderOfEmojiColor else { return UICollectionReusableView() }
        header.configure(with: section.title)
        return header
    }
}

extension NewHabitViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        
        switch section {
        case .emoji:
            selectedEmojiIndex = indexPath.item
            collectionView.reloadSections(IndexSet(integer: Section.emoji.rawValue))
        case .color:
            selectedColorIndex = indexPath.item
            collectionView.reloadSections(IndexSet(integer: Section.color.rawValue))
        }
        conditionCreateButton()
    }
}
