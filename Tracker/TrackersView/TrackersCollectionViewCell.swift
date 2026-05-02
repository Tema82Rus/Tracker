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
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    // MARK: - Private Properties
    private let cornerRadius: CGFloat = 16.0
    
    // MARK: - Static Properties
    static let reuseIdentifier: String = "TrackersCollectionViewCell"
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTitle()
        setupColorForCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override Methods
    override func layoutSubviews() {
        super.layoutSubviews()
        setupCornerRadius()
    }
    
    // MARK: - Private Methods
    private func setupTitle() {
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12)
        ])
    }
    
    private func setupColorForCell() {
        contentView.backgroundColor = .systemGreen
    }
    
    private func setupCornerRadius() {
        print("Content view frame: \(contentView.frame)") // TODO: размер 176 вместо 167 исправить
        contentView.layer.cornerRadius = cornerRadius
        contentView.layer.masksToBounds = true
    }
}
