//
//  InviteFriendViewController.swift
//  Packsync
//
//  Created by Jessica on 10/24/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class InviteFriendViewController: UIViewController {
    
    let inviteFriendView = InviteFriendView()
    let firestore = Firestore.firestore()  // Firestore instance

    override func loadView() {
        view = inviteFriendView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "INVITE A FRIEND"
        view.backgroundColor = .white
        
        // Check if the user is signed in
        if let currentUser = Auth.auth().currentUser {
            print("Current user is signed in with UID: \(currentUser.uid)")
        } else {
            print("No user is currently signed in.")
            showAlert("Please log in to invite a friend")
            // Optionally, navigate to the login screen here
        }
        
        // Configure the invite button action
        inviteFriendView.configureInviteAction(target: self, action: #selector(sendInvite))
    }

    @objc private func sendInvite() {
        // Check if the user is signed in before proceeding
        guard let currentUser = Auth.auth().currentUser else {
            print("No user is currently signed in.")
            showAlert("Please log in to invite a friend")
            return
        }
        
        print("Current user is signed in with UID: \(currentUser.uid)")

        guard let email = inviteFriendView.emailTextField.text, !email.isEmpty else {
            showAlert("Please enter an email address")
            return
        }
        
        // Check if the user with the entered email exists in Firestore
        findUserByEmail(email) { [weak self] userId in
            guard let self = self else { return }
            if let userId = userId {
                self.sendInvitation(to: userId) { success in
                    if success {
                        self.inviteFriendView.showConfirmationMessage()
                    } else {
                        self.showAlert("Failed to send invitation")
                    }
                }
            } else {
                self.showAlert("No user found with that email")
            }
        }
    }
    
    private func findUserByEmail(_ email: String, completion: @escaping (String?) -> Void) {
        firestore.collection("users")
            .whereField("email", isEqualTo: email)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error finding user: \(error)")
                    completion(nil)
                    return
                }
                
                if let document = querySnapshot?.documents.first {
                    completion(document.documentID)
                } else {
                    completion(nil)
                }
            }
    }

    private func sendInvitation(to userId: String, completion: @escaping (Bool) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            print("User is not logged in.")
            completion(false)
            return
        }
        
        let currentUserId = currentUser.uid
        let currentUserName = currentUser.displayName ?? "Unknown User"  // Use a default name if displayName is nil

        let invitationData: [String: Any] = [
            "inviterId": currentUserId,
            "inviterName": currentUserName,
            "status": "pending",
            "timestamp": Timestamp()
        ]
        
        firestore.collection("users")
            .document(userId)
            .collection("invitations")
            .addDocument(data: invitationData) { error in
                if let error = error {
                    print("Error sending invitation: \(error)")
                    completion(false)
                } else {
                    print("Invitation sent successfully")
                    completion(true)
                }
            }
    }

    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}

