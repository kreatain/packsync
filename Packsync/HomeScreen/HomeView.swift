//
//  HomeView.swift
//  Packsync
//
//  Created by 许多 on 10/24/24.
//

import UIKit

class HomeView: UIView {
    let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to TravelCrew!"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let getStartedButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Get Started", for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .white
        addSubview(welcomeLabel)
        addSubview(getStartedButton)
        
        NSLayoutConstraint.activate([
            // Welcome Label Constraints
            welcomeLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 40),
            welcomeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            // Get Started Button Constraints
            getStartedButton.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 20),
            getStartedButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            getStartedButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
}
