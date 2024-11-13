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
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let buttonTakePhoto: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .black
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

    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Name"
        textField.borderStyle = .roundedRect
        textField.isUserInteractionEnabled = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.isUserInteractionEnabled = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 8
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
        addSubview(profileImageView)
        addSubview(buttonTakePhoto)
        addSubview(editPhotoLabel)
        addSubview(nameTextField)
        addSubview(emailTextField)
        addSubview(editButton)

        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 40),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),

            buttonTakePhoto.centerXAnchor.constraint(equalTo: centerXAnchor),
            buttonTakePhoto.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),

            editPhotoLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            editPhotoLabel.topAnchor.constraint(equalTo: buttonTakePhoto.bottomAnchor, constant: 5),

            nameTextField.topAnchor.constraint(equalTo: editPhotoLabel.bottomAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            nameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),

            emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 15),
            emailTextField.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),

            editButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 25),
            editButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            editButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            editButton.heightAnchor.constraint(equalToConstant: 50)
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
