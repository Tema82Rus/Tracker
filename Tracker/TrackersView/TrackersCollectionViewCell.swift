//
//  TrackersCollectionViewCell.swift
//  Tracker
//
//  Created by Artem Yaroshenko on 30.04.2026.
//

import UIKit

final class TrackersCollectionViewCell: UICollectionViewCell {
    // MARK: - Public Properties
    lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.font = .systemFont(ofSize: 12, weight: .medium)
        title.textColor = .ypWhite
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    lazy var counter: UILabel = {
        let title = UILabel()
        title.font = .systemFont(ofSize: 12, weight: .medium)
        title.textColor = .blackDay
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    // MARK: - Private Properties
    private lazy var buttonCompleted: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(resource: .plus), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var topView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var emoji: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        view.backgroundColor = .backgroundDay
        view.layer.cornerRadius = view.bounds.width / 2
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let cornerRadius: CGFloat = 16.0
    
    // MARK: - Static Properties
    static let reuseIdentifier: String = "TrackersCollectionViewCell"
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        setupColorForCell()
        setupColorForButton()
        setupButtonCompleted()
        changeCounter()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override Methods
    override func layoutSubviews() {
        super.layoutSubviews()
        setupCornerRadius()
        buttonCompleted.layer.cornerRadius = buttonCompleted.bounds.width / 2
        buttonCompleted.clipsToBounds = true
    }
    
    // MARK: - Private Methods
    private func setupButtonCompleted() {
        buttonCompleted.addTarget(self,
                                  action: #selector(buttonCompletedTapped),
                                  for: .touchUpInside
        )
    }
    
    private func setupColorForCell() {
        topView.backgroundColor = .systemGreen
    }
    
    private func setupColorForButton() {
        buttonCompleted.tintColor = topView.backgroundColor
    }
    
    private func changeCounter() {
        counter.text = "0 дней"
    }
    
    @objc private func buttonCompletedTapped() {
        print("Трекер выполнен")
    }
    
    private func setupViews() {
        contentView.addSubview(topView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(counter)
        contentView.addSubview(buttonCompleted)
        contentView.addSubview(emoji)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: contentView.topAnchor),
            topView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topView.heightAnchor.constraint(equalToConstant: 90),
            
            titleLabel.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -12),
            titleLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 12),
            
            counter.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 16),
            counter.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            counter.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            buttonCompleted.widthAnchor.constraint(equalToConstant: 34),
            buttonCompleted.heightAnchor.constraint(equalToConstant: 34),
            buttonCompleted.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            buttonCompleted.centerYAnchor.constraint(equalTo: counter.centerYAnchor),
            
            emoji.widthAnchor.constraint(equalToConstant: 24),
            emoji.heightAnchor.constraint(equalToConstant: 24),
            emoji.topAnchor.constraint(equalTo: topView.topAnchor, constant: 12),
            emoji.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 12)
        ])
    }
    
    private func setupCornerRadius() {
        print("Content view frame: \(contentView.frame)") // TODO: длина ячейки 176 вместо 167
        topView.layer.cornerRadius = cornerRadius
        topView.clipsToBounds = true
    }
}
