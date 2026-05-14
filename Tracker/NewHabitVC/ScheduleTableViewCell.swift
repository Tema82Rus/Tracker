//
//  ScheduleTableViewCell.swift
//  Tracker
//
//  Created by Artem Yaroshenko on 09.05.2026.
//

import UIKit

final class ScheduleTableViewCell: UITableViewCell {
    // MARK: - Public Properties
    var onToggle: ((Bool) -> Void)?
    
    // MARK: - Private Properties
    private lazy var weekDayTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .blackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.onTintColor = .appBlue
        switchControl.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .appGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Static Properties
    static let reuseIdentifier: String = "TableViewCell"
    
    // MARK: - Initialisers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Override methods
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //switchControl.isOn = selected
        //На будущее попробую сделать нажатие не только на свич а по всей ячейке
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onToggle = nil
        switchControl.removeTarget(nil, action: nil, for: .allEvents)
    }
    
    // MARK: - Public Methods
    func configure(
        with day: WeekDay,
        isSelected: Bool,
        onToggle: @escaping (Bool) -> Void,
        isLast: Bool = false
    ) {
        backgroundColor = .clear
        weekDayTitleLabel.text = day.title
        switchControl.isOn = isSelected
        self.onToggle = onToggle
        separatorView.isHidden = isLast
    }
    
    // MARK: - Private Methods
    @objc private func switchValueChanged(_ sender: UISwitch) {
        onToggle?(sender.isOn)
    }
    
    private func setupViews() {
        contentView.addSubview(weekDayTitleLabel)
        contentView.addSubview(switchControl)
        contentView.addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            weekDayTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            weekDayTitleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}

//#Preview {
//    ScheduleVC()
//}
