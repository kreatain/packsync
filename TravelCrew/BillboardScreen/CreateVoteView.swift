//
//  CreateVoteView.swift
//  Packsync
//
//  Created by 许多 on 11/15/24.
//

import UIKit

class CreateVoteView: UIView {

    // UI Components
    let titleTextField = UITextField()
    var choiceTextFields: [UITextField] = []
    let stackView = UIStackView()
    let addButton = UIButton(type: .system)
    let publishButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Setup UI elements
    private func setupUI() {
        self.backgroundColor = .white

        // Title text field setup
        titleTextField.placeholder = "Enter vote title..."
        titleTextField.borderStyle = .roundedRect
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleTextField)

        // Stack view setup for choices
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        // Initial choice text field
        addChoiceTextField()

        // Add button setup
        addButton.setTitle("Add Choice", for: .normal)
        addButton.setTitleColor(.systemBlue, for: .normal)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(addButton)

        // Publish button setup
        publishButton.setTitle("Publish", for: .normal)
        publishButton.backgroundColor = .systemBlue
        publishButton.setTitleColor(.white, for: .normal)
        publishButton.layer.cornerRadius = 8
        publishButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(publishButton)
    }

    // Method to add a new choice text field
    func addChoiceTextField() {
        let choiceTextField = UITextField()
        choiceTextField.placeholder = "Enter choice..."
        choiceTextField.borderStyle = .roundedRect
        choiceTextField.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(choiceTextField)
        choiceTextFields.append(choiceTextField)
    }

    // Setup Auto Layout constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Title text field constraints
            titleTextField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 40),

            // Stack view constraints
            stackView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            // Add button constraints
            addButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            addButton.centerXAnchor.constraint(equalTo: centerXAnchor),

            // Publish button constraints
            publishButton.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 20),
            publishButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            publishButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            publishButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}
