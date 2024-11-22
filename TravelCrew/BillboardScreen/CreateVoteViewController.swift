//
//  CreateVoteViewController.swift
//  Packsync
//
//  Created by 许多 on 11/15/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class CreateVoteViewController: UIViewController {

    private let createVoteView = CreateVoteView()
    var travelId: String
    init(travelId: String) {
            self.travelId = travelId
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    override func loadView() {
        view = createVoteView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
    }

    // Setup the view controller
    private func setupViewController() {
        title = "Create Vote"
        view.backgroundColor = .white

        // Add actions for buttons
        createVoteView.addButton.addTarget(self, action: #selector(addChoiceTapped), for: .touchUpInside)
        createVoteView.publishButton.addTarget(self, action: #selector(publishTapped), for: .touchUpInside)
    }

    // Action for the "Add Choice" button
    @objc private func addChoiceTapped() {
        createVoteView.addChoiceTextField()
        print("Added a new choice text field.")
    }

    @objc private func publishTapped() {
        // Get the vote title and choices
        let title = createVoteView.titleTextField.text ?? ""
        let choices = createVoteView.choiceTextFields.compactMap { $0.text }.filter { !$0.isEmpty }

        // Validate the vote title
        guard !title.isEmpty else {
            showAlert(message: "Vote title cannot be empty.")
            return
        }

        // Validate that there are at least two choices
        guard choices.count >= 2 else {
            showAlert(message: "At least two choices are required.")
            return
        }

        // Use the travelId passed during initialization
        guard let authorId = Auth.auth().currentUser?.uid else {
            print("User is not authenticated.")
            return
        }

        // Create a unique ID for the vote
        let billboardId = UUID().uuidString

        // Initialize the votes dictionary with 0 counts for each choice
        let votes = Dictionary(uniqueKeysWithValues: choices.map { ($0, 0) })

        // Create the Billboard object for the vote
        let vote = Billboard(
            id: billboardId,
            travelId: self.travelId, // Use the travelId passed in
            type: "vote",
            title: title,
            choices: choices,
            votes: votes,
            createdAt: Date(),
            authorId: authorId
        )

        // Send the vote data to Firestore
        addVoteToFirestore(vote)

        // Navigate back to the previous screen
        navigationController?.popViewController(animated: true)
    }
    
    // Helper method to send vote to Firestore
    private func addVoteToFirestore(_ vote: Billboard) {
        let db = Firestore.firestore()
        let documentId = vote.id ?? UUID().uuidString

        do {
            try db.collection("billboards").document(documentId).setData(from: vote)
            print("Vote added successfully!")
        } catch let error {
            print("Error adding vote: \(error.localizedDescription)")
        }
    }

    // Helper method to show an alert
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
