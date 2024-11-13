//
//  ProfileViewController.swift
//  Packsync
//
//  Created by 许多 on 10/24/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private let profileView = ProfileView()
    
    override func loadView() {
        view = profileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        loadUserProfile() // Load user profile data when the view loads
    }
    
    private func setupActions() {
        profileView.editButton.addTarget(self, action: #selector(handleEditProfile), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleChangeProfileImage))
        profileView.profileImageView.addGestureRecognizer(tapGesture)
        profileView.profileImageView.isUserInteractionEnabled = true
    }
    
    private func loadUserProfile() {
        //guard let userID = Auth.auth().currentUser?.uid else { return }
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user is logged in.")
            return
        }
        
        let ref = Database.database().reference().child("users").child(userID)
        ref.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self, let data = snapshot.value as? [String: Any] else { return }
            
            if let name = data["name"] as? String {
                self.profileView.nameTextField.text = name
            }
            if let email = data["email"] as? String {
                self.profileView.emailTextField.text = email
            }
            if let profileImageUrl = data["profileImageUrl"] as? String {
                self.loadProfileImage(urlString: profileImageUrl)
            }
        }
    }
    
    private func loadProfileImage(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profileView.profileImageView.image = image
                }
            }
        }.resume()
    }
    
    @objc func handleEditProfile() {
        guard let userID = Auth.auth().currentUser?.uid,
              let name = profileView.nameTextField.text,
              let email = profileView.emailTextField.text else { return }
        
        // Update user information in Firebase
        let ref = Database.database().reference().child("users").child(userID)
        ref.updateChildValues(["name": name, "email": email]) { [weak self] error, _ in
            if let error = error {
                self?.showAlert("Update Failed", error.localizedDescription)
            } else {
                self?.showAlert("Profile Updated", "Your profile information has been updated.")
            }
        }
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
            uploadProfileImage(selectedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    private func uploadProfileImage(_ image: UIImage) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        
        let storageRef = Storage.storage().reference().child("profile_images").child("\(userID).jpg")
        
        storageRef.putData(imageData, metadata: nil) { [weak self] metadata, error in
            if let error = error {
                self?.showAlert("Upload Failed", error.localizedDescription)
                return
            }
            
            storageRef.downloadURL { [weak self] url, error in
                guard let self = self, let profileImageUrl = url?.absoluteString else { return }
                
                // Save the profile image URL to the database
                let ref = Database.database().reference().child("users").child(userID)
                ref.updateChildValues(["profileImageUrl": profileImageUrl]) { error, _ in
                    if let error = error {
                        self.showAlert("Update Failed", error.localizedDescription)
                    } else {
                        self.showAlert("Profile Image Updated", "Your profile picture has been updated.")
                    }
                }
            }
        }
    }
    
    private func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
