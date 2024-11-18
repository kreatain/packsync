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
import FirebaseFirestore

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    private let profileView = ProfileView()
    private var isEditingProfile = false

    private var currentUser: FirebaseAuth.User? // Declare currentUser explicitly
    private var invitations: [Invitation] = [] // Holds the list of invitations
    private let firestore = Firestore.firestore() // Firestore instance

    override func loadView() {
        view = profileView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        setupTableView()
        postLogin()
        loadUserProfile()
        print("?????????aaaaaaa")
        fetchInvitations()

        title = "Profile"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(toggleEditProfile)
        )

        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            self?.handleAuthStateChange(user: user)
        }
        
        profileView.tableView.register(InvitationCell.self, forCellReuseIdentifier: "InvitationCell")

    }

    // MARK: - Setup Actions
    private func setupActions() {
        profileView.configurePhotoButton(target: self, action: #selector(showPhotoOptions))
    }

    // MARK: - Authentication Handling
    func handleAuthStateChange(user: FirebaseAuth.User?) {
        if let user = user {
            currentUser = user
            postLogin()
        } else {
            currentUser = nil
            postLogout()
        }
    }

    func postLogin() {
        guard let currentUser = Auth.auth().currentUser else { return }
        profileView.nameTextField.text = " \(currentUser.displayName ?? "No Name")"
        profileView.emailTextField.text = " \(currentUser.email ?? "No Email")"
        loadUserProfile()
    }

    func postLogout() {
        profileView.nameTextField.text = "Please Login FIRST!!!"
        profileView.emailTextField.text = ""
        profileView.profileImageView.image = nil
    }

    // MARK: - Profile Editing
    @objc private func toggleEditProfile() {
        isEditingProfile.toggle()
        // title = isEditingProfile ? "EDIT PROFILE" : "PROFILE"
    
        navigationItem.rightBarButtonItem?.title = isEditingProfile ? "Save" : "Edit"

        if isEditingProfile {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: "Cancel",
                style: .plain,
                target: self,
                action: #selector(cancelEditing)
            )
        } else {
            navigationItem.leftBarButtonItem = nil
        }

        toggleEditing(isEditingProfile)
        if !isEditingProfile {
            saveProfileChanges()
        }
    }

    @objc private func cancelEditing() {
        isEditingProfile = false
        navigationItem.rightBarButtonItem?.title = "Edit"
        navigationItem.leftBarButtonItem = nil
        toggleEditing(false)
        loadUserProfile()
    }

    private func toggleEditing(_ enable: Bool) {
        profileView.nameTextField.isUserInteractionEnabled = enable
        profileView.emailTextField.isUserInteractionEnabled = enable
        profileView.togglePhotoEditing(enabled: enable)
    }

    // MARK: - Profile Management
    private func saveProfileChanges() {
        guard let userID = Auth.auth().currentUser?.uid,
              let name = profileView.nameTextField.text,
              let email = profileView.emailTextField.text else { return }

        firestore.collection("users").document(userID)
            .setData(["displayName": name, "email": email], merge: true)
    }

    private func loadUserProfile() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        firestore.collection("users").document(userID).getDocument { document, error in
            if let error = error {
                print("Failed to load user profile: \(error.localizedDescription)")
                return
            }

            if let document = document, let data = document.data() {
                if let profileImageUrl = data["profileImageUrl"] as? String {
                    self.loadProfileImage(urlString: profileImageUrl)
                } else {
                    self.profileView.profileImageView.image = UIImage(named: "defaultProfileImage")
                }
            }
        }
    }

    private func loadProfileImage(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.profileView.profileImageView.image = image
            }
        }.resume()
    }

    // MARK: - Invitation Handling
    private func setupTableView() {
        profileView.tableView.delegate = self
        profileView.tableView.dataSource = self
        profileView.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "InvitationCell")
    }

    private func fetchInvitations() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        currentUser = Auth.auth().currentUser
        if currentUser?.uid == "" {
            return
        }

        firestore.collection("invitations")
            .whereField("isAccepted", isEqualTo: 0)
            .whereField("receiverId", isEqualTo: currentUser?.uid)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching invitations: \(error.localizedDescription)")
                    return
                }
                self?.invitations = snapshot?.documents.compactMap { document in
                    let data = document.data()
                    return Invitation(
                        id: document.documentID,
                        inviterId: data["inviterId"] as? String ?? "",
                        receiverId: data["inviterName"] as? String ?? "",
                        travelId: data["travelId"] as? String ?? "",
                        isAccepted: data["isAccepted"] as? Int ?? 0,
                        timestamp: data["timestamp"] as? Date,
                        inviterName: data["inviterName"] as? String ?? ""
                    )
                } ?? []

                DispatchQueue.main.async {
                    self?.profileView.tableView.reloadData()
                }
            }
    }

    // MARK: - Invitation Handling

    // Add the methods here
    @objc private func handleAcceptButton(_ sender: UIButton) {
        let index = sender.tag
        guard index < invitations.count else { return }
        let invitation = invitations[index]
        updateInvitationStatus(invitation, to: 1)
    }

    @objc private func handleRejectButton(_ sender: UIButton) {
        let index = sender.tag
        guard index < invitations.count else { return }
        let invitation = invitations[index]
        updateInvitationStatus(invitation, to: 2)
    }

    // Existing method
    private func updateInvitationStatus(_ invitation: Invitation, to status: Int) {
        firestore.collection("invitations")
            .document(invitation.id)
            .updateData(["isAccepted": status]) { error in
                if let error = error {
                    print("Failed to update invitation status: \(error.localizedDescription)")
                } else {
                    print("Invitation status updated to \(status)")
                    self.fetchInvitations() // Refresh invitations
                }
            }
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invitations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InvitationCell", for: indexPath) as? InvitationCell else {
            return UITableViewCell()
        }

        let invitation = invitations[indexPath.row]
        let inviterName = invitation.inviterName ?? "Someone" // Provide a default value if inviterName is nil
        cell.invitationLabel.text = "Trip Alert! \(inviterName) invited you. Ready to go?"
        cell.acceptButton.tag = indexPath.row
        cell.rejectButton.tag = indexPath.row

        cell.acceptButton.addTarget(self, action: #selector(handleAcceptButton(_:)), for: .touchUpInside)
        cell.rejectButton.addTarget(self, action: #selector(handleRejectButton(_:)), for: .touchUpInside)

        return cell
    }




    // MARK: - Photo Actions
    @objc private func showPhotoOptions() {
        let actionSheet = UIAlertController(title: "Select Photo", message: "Choose a source", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in self.pickUsingCamera() }))
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in self.pickPhotoFromGallery() }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true)
    }

    private func pickUsingCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            picker.allowsEditing = true
            present(picker, animated: true)
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
                        self?.profileView.buttonTakePhoto.setImage(nil, for: .normal)
                    }
                }
            }
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.editedImage] as? UIImage {
            profileView.profileImageView.image = selectedImage
            uploadProfileImage(selectedImage)
            profileView.buttonTakePhoto.setImage(nil, for: .normal)
        }
        picker.dismiss(animated: true)
    }

    private func uploadProfileImage(_ image: UIImage) {
        guard let userID = Auth.auth().currentUser?.uid,
              let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        let storageRef = Storage.storage().reference().child("profile_images").child("\(userID).jpg")
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Failed to upload image: \(error.localizedDescription)")
                return
            }
            storageRef.downloadURL { url, error in
                guard let profileImageUrl = url?.absoluteString else { return }
                self.firestore.collection("users").document(userID).setData(
                    ["profileImageUrl": profileImageUrl], merge: true
                )
            }
        }
    }

    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}


