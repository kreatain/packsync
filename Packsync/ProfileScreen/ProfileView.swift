//
//  ProfileView.swift
//  Packsync
//
//  Created by Jessica on 10/24/24.
//

import UIKit

class ProfileView: UIView {

    // UI Elements
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 60  // Adjust size as desired
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let buttonTakePhoto: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 30), forImageIn: .normal)
        button.tintColor = .darkGray
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true  // Initially hidden until edit mode is enabled
        return button
    }()

    let editPhotoLabel: UILabel = {
        let label = UILabel()
        label.text = "Edit Photo"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true  // Initially hidden until edit mode is enabled
        return label
    }()

    let nameTextField: UILabel = {
        let textField = UILabel()
        textField.text = "Name: "
        textField.textColor = .black
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        textField.adjustsFontSizeToFitWidth = true  // Adjusts font size when text is too long
        textField.minimumScaleFactor = 0.5  // Minimum scale factor for font size adjustment
        textField.lineBreakMode = .byTruncatingTail  // Truncate text with ellipsis if it's too long
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    let emailTextField: UILabel = {
        let textField = UILabel()
        textField.text = "Email: "
        textField.textColor = .black
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        textField.adjustsFontSizeToFitWidth = true  // Adjusts font size when text is too long
        textField.minimumScaleFactor = 0.5  // Minimum scale factor for font size adjustment
        textField.lineBreakMode = .byTruncatingTail  // Truncate text with ellipsis if it's too long
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
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

        // Add all UI components to the view
        addSubview(profileImageView)
        addSubview(buttonTakePhoto)
        addSubview(editPhotoLabel)
        addSubview(nameTextField)
        addSubview(emailTextField)

        // Set up layout constraints
        NSLayoutConstraint.activate([
            // Profile Image View Constraints
            profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),

            // Take Photo Button Constraints (Positioned below the profile image and above the "Edit Photo" label)
            buttonTakePhoto.centerXAnchor.constraint(equalTo: centerXAnchor),
            buttonTakePhoto.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            buttonTakePhoto.widthAnchor.constraint(equalToConstant: 40),
            buttonTakePhoto.heightAnchor.constraint(equalToConstant: 40),

            // Edit Photo Label Constraints
            editPhotoLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            editPhotoLabel.topAnchor.constraint(equalTo: buttonTakePhoto.bottomAnchor, constant: 5),

            // Name TextField Constraints
            nameTextField.topAnchor.constraint(equalTo: editPhotoLabel.bottomAnchor, constant: 15),
            nameTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            nameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),

            // Email TextField Constraints
            emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 15),
            emailTextField.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor)
        ])
    }

    func configurePhotoButton(target: Any, action: Selector) {
        buttonTakePhoto.addTarget(target, action: action, for: .touchUpInside)
    }

    // Toggle visibility of photo elements based on edit mode
    func togglePhotoEditing(enabled: Bool) {
        buttonTakePhoto.isHidden = !enabled
        editPhotoLabel.isHidden = !enabled
    }
}


