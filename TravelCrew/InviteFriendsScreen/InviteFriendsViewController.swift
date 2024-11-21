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
    let travelID: String
    let travelTitle: String
    let db = Firestore.firestore()

    init(travelID: String, travelTitle: String) {
        self.travelID = travelID
        self.travelTitle = travelTitle
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = inviteFriendView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Invite Friend"
        
        inviteFriendView.buttonSendInvitation.addTarget(self, action: #selector(sendInvitationTapped), for: .touchUpInside)
    }

    @objc func sendInvitationTapped() {
        guard let email = inviteFriendView.textFieldEmail.text, !email.isEmpty else {
            showAlert(title: "Error", message: "Please enter a valid email address.")
            return
        }

        // First, find the user with the given email
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }

            if let error = error {
                print("Error getting documents: \(error)")
                self.showAlert(title: "Error", message: "An error occurred while searching for the user.")
                return
            }

            guard let document = querySnapshot?.documents.first else {
                self.showAlert(title: "User Not Found", message: "No user found with the provided email address.")
                return
            }

            guard let receiverUser = try? document.data(as: User.self) else {
                self.showAlert(title: "Error", message: "Failed to parse user data.")
                return
            }

            self.sendInvitation(to: receiverUser)
        }
    }

    func sendInvitation(to receiver: User) {
        guard let currentUser = Auth.auth().currentUser else {
            showAlert(title: "Error", message: "You must be logged in to send invitations.")
            return
        }

        let invitation = Invitation(
            inviterId: currentUser.uid,
            receiverId: receiver.id,
            travelId: self.travelID,
            travelTitle: self.travelTitle,
            inviterName: currentUser.displayName
        )

        do {
            try db.collection("invitations").document(invitation.id).setData(from: invitation)
            showAlert(title: "Success", message: "Invitation sent successfully!")
        } catch {
            print("Error sending invitation: \(error)")
            showAlert(title: "Error", message: "Failed to send invitation. Please try again.")
        }
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
