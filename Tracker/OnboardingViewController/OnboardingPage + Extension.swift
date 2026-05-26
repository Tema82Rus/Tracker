//
//  OnboardingPage + Extension.swift
//  Tracker
//
//  Created by Artem Yaroshenko on 26.05.2026.
//

import UIKit

extension OnboardingViewController {
    func makePageViewController(for page: OnboardingPage) -> UIViewController {
        let vc = UIViewController()
        
        // Фон и изображение
        let backgroundImageView = UIImageView(image: page.image)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(backgroundImageView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: vc.view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor)
        ])
        
        // Заголовок
        let label = UILabel()
        label.text = page.title
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .appBlack
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        // Кнопка (только для последней страницы)
        let button = makeOnboardingButton(withTitle: page.buttonTitle)
        vc.view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 60),
            button.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -20),
            button.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 20),
            button.bottomAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
        
        
        return vc
    }
    
    private func makeOnboardingButton(withTitle title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = .appBlack
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.contentHorizontalAlignment = .center
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(onboardingButtonTapped), for: .touchUpInside)
        return button
    }
}

// Для обработки нажатия кнопки создадим extension у UIViewController
private extension UIPageViewController {
    @objc func onboardingButtonTapped() {
        UserDefaults.standard.set(true, forKey: "onboardingWasShown")
        let tabBC = TabBarController()
        tabBC.modalPresentationStyle = .fullScreen
        present(tabBC, animated: true)
    }
}
