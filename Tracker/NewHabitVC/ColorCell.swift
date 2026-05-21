//
//  ColorCell.swift
//  Tracker
//
//  Created by Artem Yaroshenko on 14.05.2026.
//

import UIKit

final class ColorCell: UICollectionViewCell {
    // MARK: - Static Properties
    static let reuseIdentifier = "ColorCell"
    
    // MARK: - Private Properties
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Override Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        colorView.backgroundColor = nil
        contentView.layer.borderWidth = 0
        contentView.layer.borderColor = nil
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        contentView.addSubview(colorView)
        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.widthAnchor.constraint(equalToConstant: 40)
        ])
        
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
    }
    
    func configure(with color: UIColor, isSelected: Bool) {
        colorView.backgroundColor = color
        
        if isSelected {
            contentView.layer.borderWidth = 3
            contentView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        } else {
            contentView.layer.borderWidth = 0
            contentView.layer.borderColor = nil
        }
    }
}
