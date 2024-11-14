//
//  ProfileViewController.swift
//  Packsync
//
//  Created by Jessica on 10/24/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import PhotosUI

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {

    private let profileView = ProfileView()
    private var isEditingProfile = false

    var handleAuth: AuthStateDidChangeListenerHandle?
    var currentUser: FirebaseAuth.User?


    override func loadView() {
        view = profileView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        loadUserProfile()
        
        // Add authentication state change listener
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            print(11111)
            self?.handleAuthStateChange(user: user)
            print(22222)
        }
    }

    // Handle authentication state changes
    func handleAuthStateChange(user: FirebaseAuth.User?) {
        if let user = user {
            // User is logged in
            currentUser = user
            print("[handleAuthStateChange] user is logged in")
            postLogin()
        } else {
            // User is logged out
            currentUser = nil
            print("[handleAuthStateChange] user is logged out")
            postLogout() // clean up
        }
    }
    
    func postLogin() {
        //let a = profileView.nameTextField.text ?? ""
        let b = currentUser?.displayName ?? ""
        profileView.nameTextField.text = "Name: "+b // TODO append text instead of replace
    }

    func postLogout() {
        profileView.nameTextField.text = "<pls login first>"
    }
    
    
    private func setupActions() {
        profileView.editButton.addTarget(self, action: #selector(toggleEditProfile), for: .touchUpInside)
        profileView.configurePhotoButton(target: self, action: #selector(showPhotoOptions))
    }

    @objc private func toggleEditProfile() {
        isEditingProfile.toggle()

        profileView.editButton.setTitle(isEditingProfile ? "Save" : "Edit Profile", for: .normal)
        toggleEditing(isEditingProfile)
        
        if !isEditingProfile {
            saveProfileChanges()
        }
    }

    private func toggleEditing(_ enable: Bool) {
        profileView.nameTextField.isUserInteractionEnabled = enable
        profileView.emailTextField.isUserInteractionEnabled = enable
        
        // Toggle photo editing elements in ProfileView
        profileView.togglePhotoEditing(enabled: enable)
        
        if enable {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showPhotoOptions))
            profileView.profileImageView.addGestureRecognizer(tapGesture)
            profileView.profileImageView.isUserInteractionEnabled = true
        } else {
            profileView.profileImageView.gestureRecognizers?.forEach { profileView.profileImageView.removeGestureRecognizer($0) }
            profileView.profileImageView.isUserInteractionEnabled = false
        }
    }

    private func loadUserProfile() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("users").child(userID)

        ref.observeSingleEvent(of: .value) { snapshot in
            guard let data = snapshot.value as? [String: Any] else { return }
            self.profileView.nameTextField.text = data["name"] as? String
            self.profileView.emailTextField.text = data["email"] as? String
            if let profileImageUrl = data["profileImageUrl"] as? String {
                self.loadProfileImage(urlString: profileImageUrl)
            }
        }
    }

    private func saveProfileChanges() {
        guard let userID = Auth.auth().currentUser?.uid,
              let name = profileView.nameTextField.text,
              let email = profileView.emailTextField.text else { return }

        let ref = Database.database().reference().child("users").child(userID)
        ref.updateChildValues(["name": name, "email": email])
    }

    private func loadProfileImage(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.profileView.profileImageView.image = image
                // Hide the camera icon once an image is loaded
                self.profileView.buttonTakePhoto.setImage(nil, for: .normal)
            }
        }.resume()
    }

    @objc private func showPhotoOptions() {
        let actionSheet = UIAlertController(title: "Select Photo", message: "Choose a source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.pickUsingCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.pickPhotoFromGallery()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
    }

    private func pickUsingCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            picker.allowsEditing = true
            present(picker, animated: true, completion: nil)
        } else {
            showAlert("Camera not available")
        }
    }

    private func pickPhotoFromGallery() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                DispatchQueue.main.async {
                    if let selectedImage = image as? UIImage {
                        self?.profileView.profileImageView.image = selectedImage
                        self?.uploadProfileImage(selectedImage)
                        // Remove the camera icon after selecting a new image
                        self?.profileView.buttonTakePhoto.setImage(nil, for: .normal)
                    }
                }
            }
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.editedImage] as? UIImage {
            profileView.profileImageView.image = selectedImage
            uploadProfileImage(selectedImage)
            // Remove the camera icon after taking a new photo
            profileView.buttonTakePhoto.setImage(nil, for: .normal)
        }
        picker.dismiss(animated: true, completion: nil)
    }

    private func uploadProfileImage(_ image: UIImage) {
        guard let userID = Auth.auth().currentUser?.uid, let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        let storageRef = Storage.storage().reference().child("profile_images").child("\(userID).jpg")
        storageRef.putData(imageData, metadata: nil) { _, error in
            if error == nil {
                storageRef.downloadURL { url, _ in
                    if let profileImageUrl = url?.absoluteString {
                        Database.database().reference().child("users").child(userID).updateChildValues(["profileImageUrl": profileImageUrl])
                    }
                }
            }
        }
    }

    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}

