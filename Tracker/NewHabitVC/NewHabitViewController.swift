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

class NewHabitViewController: UIViewController, UITextFieldDelegate {
    // MARK: Public Properties
    weak var delegate: NewHabitViewControllerDelegate?
    
    // MARK: Private Properties
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .blackDay
        label.textAlignment = .center
        label.sizeToFit()
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
        button.setTitleColor(.blackDay, for: .normal)
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
        button.setTitleColor(.blackDay, for: .normal)
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
    
    private var categoryButtonTopWhenErrorHidden: NSLayoutConstraint!
    private var categoryButtonTopWhenErrorVisible: NSLayoutConstraint!
    
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
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.titleView = titleLabel
        setupViews()
    }
    
    // MARK: Private Methods
    private func setupViews() {
        view.addSubview(textField)
        view.addSubview(errorLabel)
        view.addSubview(backgroundBlockView)
        
        backgroundBlockView.addSubview(categoryButton)
        backgroundBlockView.addSubview(scheduleButton)
        backgroundBlockView.addSubview(dividerView)
        
        textField.inputAccessoryView = keyboardToolbar
        
        let stackBottomButton = UIStackView()
        stackBottomButton.axis = .horizontal
        stackBottomButton.spacing = 8
        stackBottomButton.distribution = .fillEqually
        stackBottomButton.translatesAutoresizingMaskIntoConstraints = false
        stackBottomButton.addArrangedSubview(cancelButton)
        stackBottomButton.addArrangedSubview(createButton)
        view.addSubview(stackBottomButton)
        
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = leftPaddingView
        textField.leftViewMode = .always
        
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.rightView = rightPaddingView
        textField.rightViewMode = .always
        
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            errorLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            backgroundBlockView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backgroundBlockView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            backgroundBlockView.heightAnchor.constraint(equalToConstant: 150),
            scheduleButton.bottomAnchor.constraint(lessThanOrEqualTo: view.keyboardLayoutGuide.topAnchor, constant: -24),
            
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
            
            stackBottomButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackBottomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackBottomButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stackBottomButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        categoryButtonTopWhenErrorHidden = categoryButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24)
        categoryButtonTopWhenErrorVisible = categoryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 32)
        
        categoryButtonTopWhenErrorHidden.isActive = true
    }
    
    @objc private func textFieldDidChange() {
        guard let text = textField.text else { return }
        let isOverLimit = text.count >= 38
        errorLabel.isHidden = !isOverLimit
        
        categoryButtonTopWhenErrorHidden.isActive = !isOverLimit
        categoryButtonTopWhenErrorVisible.isActive = isOverLimit
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
        guard let nameTracker = textField.text, !nameTracker.isEmpty else { return }
        let newTracker = Tracker(id: UUID(),
                                 title: nameTracker,
                                 color: .systemGreen,
                                 emoji: "✅",
                                 timeTable: selectedSchedule
        )
        let newCategoryTitle = selectedCategory
        delegate?.didCreateTracker(newTracker, categoryName: newCategoryTitle)
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
            .foregroundColor: UIColor.blackDay
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
            .foregroundColor: UIColor.blackDay
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
        let isValid = hasName && hasSchedule
        createButton.isEnabled = isValid
        createButton.backgroundColor = isValid ? .blackDay : .appGray
    }
}
