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

    let confirmationLabel: UILabel = {
        let label = UILabel()
        label.text = "Invitation Sent!!!"
        label.textColor = .purple
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.isHidden = true  // Initially hidden
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        addSubview(confirmationLabel)

        // Set up layout constraints
        NSLayoutConstraint.activate([
            emailTextField.centerXAnchor.constraint(equalTo: centerXAnchor),
            emailTextField.topAnchor.constraint(equalTo: topAnchor, constant: 150),
            emailTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 40),

            inviteButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            inviteButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 30),
            inviteButton.widthAnchor.constraint(equalToConstant: 100),
            inviteButton.heightAnchor.constraint(equalToConstant: 40),

            confirmationLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            confirmationLabel.topAnchor.constraint(equalTo: inviteButton.bottomAnchor, constant: 20)
        ])
    }

    // Configure the button action
    func configureInviteAction(target: Any, action: Selector) {
        inviteButton.addTarget(target, action: action, for: .touchUpInside)
    }

    // Function to show the confirmation message
    func showConfirmationMessage() {
        confirmationLabel.isHidden = false
    }
}
