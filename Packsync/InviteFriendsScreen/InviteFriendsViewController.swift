//
//  InviteFriendViewController.swift
//  Packsync
//
//  Created by Jessica on 10/24/24.
//

import UIKit
import FirebaseFirestore

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
        
        // Configure the invite button action
        inviteFriendView.configureInviteAction(target: self, action: #selector(sendInvite))
        
    }
    
    @objc func addTapped() {
        // Handle additional actions if needed
    }

    @objc private func sendInvite() {
        guard let email = inviteFriendView.emailTextField.text, !email.isEmpty else {
            showAlert("Please enter an email address")
            return
        }
        
        // Here we’ll add code to check if the email exists in the Firestore user collection
        // and send an invitation if the user exists.

        findUserByEmail(email) { [weak self] userId in
            guard let self = self else { return }
            if let userId = userId {
                self.sendInvitation(to: userId)
                self.showAlert("Invitation sent to \(email)")
            } else {
                self.showAlert("No user found with that email")
            }
        }
    }
    
    private func findUserByEmail(_ email: String, completion: @escaping (String?) -> Void) {
        // Query Firestore to check if a user with this email exists
        firestore.collection("users")
            .whereField("email", isEqualTo: email)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error finding user: \(error)")
                    completion(nil)
                    return
                }
                
                // Assuming we find one user with this email
                if let document = querySnapshot?.documents.first {
                    let userId = document.documentID
                    completion(userId)
                } else {
                    completion(nil)
                }
            }
    }

    private func sendInvitation(to userId: String) {
        // Access the recipient user's invitations subcollection and add an invitation
        let invitationData: [String: Any] = [
            "inviterId": "currentUserId",  // Replace with actual current user ID
            "inviterName": "currentUserName",  // Replace with actual current user name
            "status": "pending",
            "timestamp": Timestamp()
        ]
        
        firestore.collection("users")
            .document(userId)
            .collection("invitations")
            .addDocument(data: invitationData) { error in
                if let error = error {
                    print("Error sending invitation: \(error)")
                } else {
                    print("Invitation sent successfully")
                }
            }
    }

    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}

