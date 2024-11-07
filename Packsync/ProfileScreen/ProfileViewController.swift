//
//  ProfileViewController.swift
//  Packsync
//
//  Created by 许多 on 10/24/24.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private let profileView = ProfileView()
    
    override func loadView() {
        view = profileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
    }
    
    private func setupActions() {
        profileView.editButton.addTarget(self, action: #selector(handleEditProfile), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleChangeProfileImage))
        profileView.profileImageView.addGestureRecognizer(tapGesture)
        profileView.profileImageView.isUserInteractionEnabled = true
    }
    
    @objc func handleEditProfile() {
        // Code to edit profile, e.g., update name, password, etc.
    }
    
    @objc func handleChangeProfileImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            profileView.profileImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
}

