//
//  TrackersCollectionViewCell.swift
//  Tracker
//
//  Created by Artem Yaroshenko on 30.04.2026.
//

import UIKit

protocol TrackerCellDelegate: AnyObject {
    func didAddCompletion(for tracker: Tracker, on date: Date)
    func removeAddCompletion(for tracker: Tracker, on date: Date)
}

final class TrackersCollectionViewCell: UICollectionViewCell {
    // MARK: Public Properties
    weak var delegate: TrackerCellDelegate?
    
    // MARK: - Private Properties
    private lazy var emojiLabelBackgroundView: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.backgroundDay
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .blackDay
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.font = .systemFont(ofSize: 12, weight: .medium)
        title.textColor = .ypWhite
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    private lazy var counterLabel: UILabel = {
        let title = UILabel()
        title.font = .systemFont(ofSize: 12, weight: .medium)
        title.textColor = .blackDay
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    private lazy var completeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(resource: .plus), for: .normal)
        button.setImage(UIImage(resource: .done), for: .selected)
        button.addTarget(self,
                         action: #selector(buttonCompletedTapped),
                         for: .touchUpInside
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var cellColorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var tracker: Tracker?
    private var isCompleted = false
    private var completionCount = 0
    private var selectedDate: Date?
    // MARK: - Static Properties
    static let reuseIdentifier: String = "TrackersCollectionViewCell"
    
    // MARK: - Initialisers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        //setupCell(color: .systemGreen)
        setupCell(count: 0)
        //setupCell(emoji: "😪")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func setupCell(title: String) {
        titleLabel.text = title
    }
    
    func setupCell(count: Int) {
        counterLabel.text = "\(count) дней"
    }
    
    func setupCell(color: UIColor) {
        cellColorView.backgroundColor = color
        setupCell(colorButton: color)
    }
    
    func setupCell(colorButton: UIColor) {
        completeButton.tintColor = colorButton
    }
    
    func setupCell(emoji: String) {
        emojiLabel.text = emoji
    }
    
    func setupCell(tracker: Tracker) {
        setupCell(title: tracker.title)
        setupCell(color: tracker.color)
        setupCell(emoji: tracker.emoji)
    }
    
    func setupCell(completed: Bool) {
        isCompleted = completed
    }
    
    func setupTracker(tracker: Tracker) {
        self.tracker = tracker
        if isCompleted {
            completeButton.isSelected = true
            setupCell(count: completionCount)
        }
    }
    
    func setupSelectedDate(date: Date) {
        selectedDate = date
    }
    
    // MARK: - Private Methods
    @objc private func buttonCompletedTapped() {
        guard let tracker = tracker, let selectedDate = selectedDate else { return }
        
        if !isFutureDate(selectedDate) {
            isCompleted = !isCompleted
            completeButton.isSelected = isCompleted
            
            if isCompleted {
                completionCount += 1
                delegate?.didAddCompletion(for: tracker, on: selectedDate)
            } else {
                completionCount -= 1
                delegate?.removeAddCompletion(for: tracker, on: selectedDate)
            }
            
            setupCell(count: completionCount)
            
            
        } else {
            print("Нельзя отметить карточку для будущей даты")
        }
    }
    
    private func isFutureDate(_ date: Date) -> Bool {
        return date > Date()
    }
    
    private func setupViews() {
        contentView.addSubview(cellColorView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(counterLabel)
        contentView.addSubview(completeButton)
        emojiLabelBackgroundView.addSubview(emojiLabel)
        contentView.addSubview(emojiLabelBackgroundView)
        
        NSLayoutConstraint.activate([
            cellColorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cellColorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellColorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cellColorView.heightAnchor.constraint(equalToConstant: 90),
            
            titleLabel.bottomAnchor.constraint(equalTo: cellColorView.bottomAnchor, constant: -12),
            titleLabel.leadingAnchor.constraint(equalTo: cellColorView.leadingAnchor, constant: 12),
            
            counterLabel.topAnchor.constraint(equalTo: cellColorView.bottomAnchor, constant: 16),
            counterLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            counterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            completeButton.widthAnchor.constraint(equalToConstant: 34),
            completeButton.heightAnchor.constraint(equalToConstant: 34),
            completeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            completeButton.centerYAnchor.constraint(equalTo: counterLabel.centerYAnchor),
            
            emojiLabelBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiLabelBackgroundView.heightAnchor.constraint(equalToConstant: 24),
            emojiLabelBackgroundView.topAnchor.constraint(equalTo: cellColorView.topAnchor, constant: 12),
            emojiLabelBackgroundView.leadingAnchor.constraint(equalTo: cellColorView.leadingAnchor, constant: 12),
            emojiLabel.centerXAnchor.constraint(equalTo: emojiLabelBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiLabelBackgroundView.centerYAnchor),
        ])
    }
}
