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
        // Ensure the user is signed in before proceeding
        guard let currentUser = Auth.auth().currentUser else {
            print("❌ No user is currently signed in.")
            showAlert("Please log in to invite a friend")
            return
        }

        print("ℹ️ Current user is signed in with UID: \(currentUser.uid)")

        // Check if the email field is not empty
        guard let email = inviteFriendView.emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty else {
            showAlert("Please enter an email address")
            return
        }

        // Debugging: log the email being processed
        print("🔥 Attempting to send invite to email: \(email)")

        // Check if the user is trying to invite themselves
        guard email.lowercased() != currentUser.email?.lowercased() else {
            showAlert("You cannot invite yourself")
            return
        }

        // Find the user by their email
        findUserByEmail(email) { [weak self] userId in
            guard let self = self else { return }

            if let userId = userId {
                print("✅ Found user ID for email \(email): \(userId)")
                self.sendInvitation(to: userId) { success in
                    if success {
                        print("✅ Invitation successfully sent to \(email)")
                        self.inviteFriendView.showConfirmationMessage()
                    } else {
                        print("❌ Failed to send invitation to \(email)")
                        self.showAlert("Failed to send invitation")
                    }
                }
            } else {
                print("❌ No user found with email \(email)")
                self.showAlert("No user found with that email")
            }
        }
    }

    
    private func findUserByEmail(_ email: String, completion: @escaping (String?) -> Void) {
        // Normalize email (trim spaces and lowercase it)
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        print("🔥 Searching for email: \(normalizedEmail)") // Debugging log

        firestore.collection("users")
            .whereField("email", isEqualTo: normalizedEmail) // Ensure the field name matches Firestore
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("❌ Error finding user: \(error.localizedDescription)") // Log any error
                    completion(nil) // Return nil on error
                    return
                }

                // Check if we got any documents
                guard let document = querySnapshot?.documents.first else {
                    print("❌ No document found for email: \(normalizedEmail)") // Log no result
                    completion(nil)
                    return
                }

                // Debugging output: print the found document data
                print("✅ User found: \(document.data())")
                completion(document.documentID) // Return the document ID
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

