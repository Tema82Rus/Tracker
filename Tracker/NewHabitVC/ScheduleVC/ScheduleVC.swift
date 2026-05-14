//
//  ScheduleVC.swift
//  Tracker
//
//  Created by Artem Yaroshenko on 06.05.2026.
//

import UIKit

final class ScheduleVC: UIViewController {
    // MARK: - Public Properties
    var selectedDays: Set<WeekDay> = []
    var onSave: ((Set<WeekDay>) -> Void)?
    
    // MARK: - Private Properties
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .appBlack
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()
    
    private lazy var tableViewBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundDay
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.register(ScheduleTableViewCell.self, forCellReuseIdentifier: ScheduleTableViewCell.reuseIdentifier)
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .appBlack
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.contentHorizontalAlignment = .center
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(dismissScheduleVC), for: .touchUpInside)
        return button
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        navigationItem.titleView = titleLabel
        navigationItem.hidesBackButton = true
        tableView.dataSource = self
        tableView.delegate = self
        setupViews()
    }
    
    // MARK: - Private Methods
    @objc private func dismissScheduleVC() {
        onSave?(selectedDays)
        print(selectedDays)
        navigationController?.popViewController(animated: true)
    }
    
    private func updateSelection(for day: WeekDay, isOn: Bool) {
        if isOn {
            selectedDays.insert(day)
        } else {
            selectedDays.remove(day)
        }
    }
    
    private func setupViews() {
        view.addSubview(tableViewBackground)
        view.addSubview(doneButton)
        tableViewBackground.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableViewBackground.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableViewBackground.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -47),
            tableViewBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableViewBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: tableViewBackground.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: tableViewBackground.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: tableViewBackground.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: tableViewBackground.trailingAnchor),

            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
            
        ])
    }
}

// MARK: - UITableViewDataSource
extension ScheduleVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        WeekDay.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleTableViewCell.reuseIdentifier, for: indexPath) as? ScheduleTableViewCell else {
            return UITableViewCell()
        }
        let day = WeekDay.allCases[indexPath.row]
        let isLast = indexPath.row == WeekDay.allCases.count - 1
        let isSelected = selectedDays.contains(day)
        
        cell.configure(
            with: day,
            isSelected: isSelected,
            onToggle: { [weak self] isOn in
                guard let strongSelf = self else { return }
                strongSelf.updateSelection(for: day, isOn: isOn)
            }, isLast: isLast
        )
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ScheduleVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableViewBackground.frame.height / 7
    }
}

// MARK: - Preview
//#Preview {
//    ScheduleVC()
//}
