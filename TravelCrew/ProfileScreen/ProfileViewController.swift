//
//  ProfileViewController.swift
//  Packsync
//
//  Created by Jessica on 10/24/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    let profileView = ProfileView()
    var currentUser: User?
    var invitations: [Invitation] = []
    let db = Firestore.firestore()
    let storage = Storage.storage()

    override func loadView() {
        view = profileView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"

        profileView.tableViewInvitations.dataSource = self
        profileView.tableViewInvitations.delegate = self
        
        // Add target for edit button to upload image or take a photo
        profileView.buttonEditProfilePic.addTarget(self, action: #selector(editProfilePictureTapped), for: .touchUpInside)

        fetchCurrentUser()
        fetchInvitations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCurrentUser() // Refresh user data when the view appears
        fetchInvitations() // Refresh invitations as well
    }

    @objc func editProfilePictureTapped() {
        let alertController = UIAlertController(title: "Select Photo", message: "Choose a photo from your library or take a new one.", preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title:"Camera", style:.default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePickerController = UIImagePickerController()
                imagePickerController.sourceType = .camera
                imagePickerController.delegate = self
                self.present(imagePickerController, animated:true)
            }
        })

        alertController.addAction(UIAlertAction(title:"Photo Library", style:.default) { _ in
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.delegate = self
            self.present(imagePickerController, animated:true)
        })

        alertController.addAction(UIAlertAction(title:"Cancel", style:.cancel))

        present(alertController, animated:true)
    }

    // MARK: - UIImagePickerControllerDelegate

    func imagePickerController(_ picker:UIImagePickerController, didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            profileView.imageViewProfilePic.image = selectedImage
            
            // Upload the selected image and update the user's profile picture URL in Firestore.
            uploadImage(selectedImage) { [weak self] url in
                guard let self = self else { return }
                self.updateUserProfilePicture(url)
            }
        }
        dismiss(animated:true)
    }

    func imagePickerControllerDidCancel(_ picker:UIImagePickerController) {
        dismiss(animated:true)
    }

    func uploadImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }

        // Convert UIImage to Data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }

        // Create a storage reference
        let storageRef = storage.reference().child("profileImages/\(userId).jpg")

        // Upload the image data to Firebase Storage
        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error uploading image: \(error)")
                completion(nil)
                return
            }

            // Get the download URL for the uploaded image
            storageRef.downloadURL { (url, error) in
                if let error = error {
                    print("Error getting download URL: \(error)")
                    completion(nil)
                    return
                }

                // Return the download URL as string
                completion(url?.absoluteString)
            }
        }
    }

    func updateUserProfilePicture(_ url: String?) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        
        // Update Firestore with new profile picture URL
        db.collection("users").document(userId).updateData([
            "profilePicURL": url ?? ""
        ]) { error in
            if let error = error {
                print("Error updating user profile picture URL: \(error)")
            } else {
                print("Successfully updated user profile picture URL.")
                // Optionally reload UI or show success message here.
            }
        }
    }
    
    func fetchCurrentUser() {
        if let userId = Auth.auth().currentUser?.uid {
            db.collection("users").document(userId).getDocument { [weak self] (document, error) in
                if let document = document, document.exists {
                    self?.currentUser = try? document.data(as: User.self)
                    self?.updateUI()
                    self?.profileView.isHidden = false // Show profile view when user is signed in
                } else {
                    print("Document does not exist or error occurred: \(String(describing: error))")
                    self?.profileView.isHidden = true // Hide profile view if no document found
                }
            }
        } else {
            profileView.isHidden = true // Hide profile view when no user is signed in
        }
    }

    func updateUI() {
        profileView.labelName.text = currentUser?.displayName ?? "No Name"
        profileView.labelEmail.text = currentUser?.email

        // Load profile picture if available
        if let profilePicURL = currentUser?.profilePicURL, let url = URL(string: profilePicURL) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async { [weak self] in
                        self?.profileView.imageViewProfilePic.image = UIImage(data: data)
                    }
                }
            }
        } else {
            profileView.imageViewProfilePic.image = UIImage(named: "default_profile_pic") // Placeholder image
        }
    }


    func fetchInvitations() {
        guard let userId =
             Auth.auth().currentUser?.uid else { return }
         
         db.collection("invitations")
             .whereField("receiverId", isEqualTo:userId)
             .whereField("isAccepted", isEqualTo:
                 0) // Only fetch pending invitations
             .addSnapshotListener { [weak self] (querySnapshot,
                 error) in
                     if let error =
                         error {
                         print("Error fetching invitations: \(error)")
                         return
                     }
                     
                     self?.invitations =
                         querySnapshot?.documents.compactMap { try? $0.data(as:
                             Invitation.self) } ?? []
                     DispatchQueue.main.async {
                         self?.profileView.tableViewInvitations.reloadData()
                     }
                 }
     }

     // MARK: - UITableViewDataSource

    func tableView(_ tableView:UITableView,
                   numberOfRowsInSection section:Int) -> Int {
        return invitations.count
    }

    func tableView(_ tableView:UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"invitationCell", for:indexPath)
        let invitation = invitations[indexPath.row]
        
        // Multiline text with a clear format
        cell.textLabel?.text = """
        You're invited to \(invitation.travelTitle) by \(invitation.inviterName ?? "Unknown"). 
        Tap this message to view details!
        """
        
        // Enable multiple lines and proper wrapping
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        
        // Optional: Add a padding effect if needed by customizing the cell
        cell.textLabel?.textAlignment = .left // Ensure text alignment is appropriate
        
        return cell
    }

     // MARK: - UITableViewDelegate

     func tableView(_ tableView:UITableView,
                    didSelectRowAt indexPath:
                    IndexPath) {
         let invitation =
             invitations[indexPath.row]
         
         showAcceptInvitationAlert(invitation)
         
         // Deselect the row after selection.
         tableView.deselectRow(at:indexPath,
                                animated:true)
     }

     func showAcceptInvitationAlert(_ invitation:
                                     Invitation) {
         let alertController =
             UIAlertController(title:"Respond to Invitation",
                message:"Do you want to accept or reject the invitation from \(invitation.inviterName ?? "Unknown")?", preferredStyle:.alert)

         // Cancel action
          alertController.addAction(UIAlertAction(title:"Cancel", style:.cancel))
          
         // Accept action
          alertController.addAction(UIAlertAction(title:"Accept", style:.default) { [weak self] _ in
              self?.acceptInvitation(invitation)
              
              // Remove the invitation from the list and reload the table view if needed.
              if let indexPath =
                  self?.profileView.tableViewInvitations.indexPathForSelectedRow {
                  self?.invitations.remove(at:indexPath.row)
                  self?.profileView.tableViewInvitations.deleteRows(at:[indexPath], with:.automatic)
              }
          })
         
         // Reject action
         alertController.addAction(UIAlertAction(title: "Reject", style: .destructive) { [weak self] _ in
             self?.rejectInvitation(invitation)
              
             // Remove the invitation from the list and reload the table view if needed.
             if let indexPath = self?.profileView.tableViewInvitations.indexPathForSelectedRow {
                 self?.invitations.remove(at: indexPath.row)
                 self?.profileView.tableViewInvitations.deleteRows(at: [indexPath], with: .automatic)
             }
         })


          present(alertController,
                  animated:true)
      }

    func acceptInvitation(_ invitation: Invitation) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // Update the invitation status to accepted.
        db.collection("invitations").document(invitation.id).updateData(["isAccepted": 1]) { error in
            if let error = error {
                print("Error updating invitation status: \(error)")
                return
            }
            
            // Add user to travel plan's participantIds and participantNames.
            let travelRef = self.db.collection("travelPlans").document(invitation.travelId)
            self.db.runTransaction({ (transaction, errorPointer) -> Any? in
                let travelDocument: DocumentSnapshot
                do {
                    try travelDocument = transaction.getDocument(travelRef)
                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    return nil
                }
                
                guard var travelPlan = try? travelDocument.data(as: Travel.self) else {
                    let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch travel plan"])
                    errorPointer?.pointee = error
                    return nil
                }
                
                if !travelPlan.participantIds.contains(userId) {
                    travelPlan.participantIds.append(userId)
                    
                    // Fetch the user's displayName
                    let userRef = self.db.collection("users").document(userId)
                    do {
                        let userDocument = try transaction.getDocument(userRef)
                        if let displayName = userDocument.data()?["displayName"] as? String {
                            travelPlan.participantNames.append(displayName)
                        } else {
                            travelPlan.participantNames.append("Unknown User")
                        }
                    } catch {
                        print("Error fetching user document: \(error)")
                        travelPlan.participantNames.append("Unknown User")
                    }
                    
                    do {
                        try transaction.setData(from: travelPlan, forDocument: travelRef)
                    } catch let error as NSError {
                        errorPointer?.pointee = error
                        return nil
                    }
                }
                
                return nil
            }) { (_, error) in
                if let error = error {
                    print("Transaction failed while adding participant ID to travel plan \(error)")
                } else {
                    print("Successfully accepted invitation and added participant.")
                    NotificationCenter.default.post(name: .travelDataChanged, object: nil, userInfo: ["travelId": invitation.travelId])
                    self.triggerFirebaseUpdate(for: invitation.travelId)
                }
            }
            
            print("Invitation accepted.")
        }
    }
    
    
    func rejectInvitation(_ invitation: Invitation) {
        db.collection("invitations").document(invitation.id).updateData(["isAccepted": 2]) { error in
            if let error = error {
                print("Error rejecting invitation: \(error)")
                self.showAlert(title: "Error", message: "Unable to reject the invitation. Please try again.")
                return
            }
            print("Invitation rejected.")
        }
    }
    
    private func triggerFirebaseUpdate(for travelId: String) {
        let travelRef = db.collection("travelPlans").document(travelId)

        travelRef.updateData(["lastModified": FieldValue.serverTimestamp()]) { error in
            if let error = error {
                print("Error triggering Firebase update for travel plan: \(error)")
            } else {
                print("Successfully triggered Firebase update for travel plan \(travelId).")
            }
        }
    }
                           
    func showAlert(title:String,message:String) {
            let alert =
                UIAlertController(title:title,
                                  message:
                message,
                                  preferredStyle:.alert)
            alert.addAction(UIAlertAction(title:"OK", style:.default))
            present(alert,
                    animated:true)
        }
}
