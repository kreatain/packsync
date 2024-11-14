//
//  InviteFriendView.swift
//  Packsync
//
//  Created by Jessica on 10/24/24.
//


import UIKit

class InviteFriendView: UIView {

    // UI Elements
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter friend's email"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    let inviteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Invite", for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // Setup view layout and constraints
    private func setupView() {
        backgroundColor = .white

        // Add UI elements to the view
        addSubview(emailTextField)
        addSubview(inviteButton)

        // Set up layout constraints with more spacing from the top
        NSLayoutConstraint.activate([
            // Email TextField Constraints
            emailTextField.centerXAnchor.constraint(equalTo: centerXAnchor),
            emailTextField.topAnchor.constraint(equalTo: topAnchor, constant: 150),  // Increased spacing from the top
            emailTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 40),

            // Invite Button Constraints
            inviteButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            inviteButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 30),  // Spacing between text field and button
            inviteButton.widthAnchor.constraint(equalToConstant: 100),
            inviteButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    // Configure the button action
    func configureInviteAction(target: Any, action: Selector) {
        inviteButton.addTarget(target, action: action, for: .touchUpInside)
    }
}
