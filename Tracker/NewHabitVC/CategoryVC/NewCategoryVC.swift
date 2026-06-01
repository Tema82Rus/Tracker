//
//  NewCategoryVC.swift
//  Tracker
//
//  Created by Artem Yaroshenko on 24.05.2026.
//

import UIKit

final class NewCategoryViewController: UIViewController {
    
    // MARK: - Properties
    var onCategoryCreated: ((String) -> Void)?
    
    // MARK: - UI Elements
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("newcategory.textfield.placeholder", comment: "Enter category name placeholder")
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.borderStyle = .none
        textField.layer.cornerRadius = 16
        textField.backgroundColor = .appBackground
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = leftPaddingView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let cancelButton = UIBarButtonItem(
            title: NSLocalizedString("common.done", comment: "Done"),
            style: .plain,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let saveButton = UIBarButtonItem(
            title: NSLocalizedString("newhabit.save.button", comment: "Save"),
            style: .done,
            target: self,
            action: #selector(saveButtonTapped)
        )
        
        toolbar.items = [cancelButton, flexibleSpace, saveButton]
        return toolbar
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("newcategory.done.button", comment: "Done button"), for: .normal)
        button.backgroundColor = .appGray
        button.setTitleColor(.appWhite, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextField()
        
        navigationItem.hidesBackButton = true
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        title = NSLocalizedString("newcategory.title", comment: "New category screen title")
        view.backgroundColor = .appWhite
        
        view.addSubview(textField)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupTextField() {
        textField.inputAccessoryView = toolbar
    }
    
    @objc private func cancelButtonTapped() {
        textField.resignFirstResponder()
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        saveCategory()
    }
    
    private func saveCategory() {
        guard let categoryName = textField.text, !categoryName.isEmpty else { return }
        onCategoryCreated?(categoryName)
        textField.resignFirstResponder()
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Actions
    @objc private func textFieldDidChange() {
        let hasText = !(textField.text?.isEmpty ?? true)
        doneButton.isEnabled = hasText
        doneButton.backgroundColor = hasText ? .appBlack : .appGray
    }
    
    @objc private func doneButtonTapped() {
        guard let categoryName = textField.text, !categoryName.isEmpty else { return }
        onCategoryCreated?(categoryName)
        
        navigationController?.popViewController(animated: true)
    }
}
