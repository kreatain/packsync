//
//  ProfileView.swift
//  Packsync
//
//  Created by 许多 on 10/24/24.
//

import UIKit

class ProfileView: UIView {
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let changePhotoLabel: UILabel = {
        let label = UILabel()
        label.text = "edit"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .yellow // Add temporary background color to debug visibility
        return label
    }()
    
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Name"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
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
    
    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Changes", for: .normal)
        button.backgroundColor = .systemGreen
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
        addSubview(changePhotoLabel) // Add the label to the view hierarchy
        addSubview(nameTextField)
        addSubview(emailTextField)
        addSubview(editButton)
        addSubview(saveButton)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Profile Image View
            profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 40),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // Change Photo Label
            changePhotoLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 5),
            changePhotoLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            // Name Text Field
            nameTextField.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            // Email Text Field
            emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 15),
            emailTextField.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            
            // Edit Button
            editButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 25),
            editButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            editButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            editButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Save Button
            saveButton.topAnchor.constraint(equalTo: editButton.bottomAnchor, constant: 15),
            saveButton.leadingAnchor.constraint(equalTo: editButton.leadingAnchor),
            saveButton.trailingAnchor.constraint(equalTo: editButton.trailingAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
