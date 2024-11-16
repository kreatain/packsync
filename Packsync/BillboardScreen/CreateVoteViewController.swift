//
//  CreateVoteViewController.swift
//  Packsync
//
//  Created by 许多 on 11/15/24.
//

import UIKit

class CreateVoteViewController: UIViewController {

    private let createVoteView = CreateVoteView()

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

    // Action for the "Publish" button
    @objc private func publishTapped() {
        let title = createVoteView.titleTextField.text ?? ""
        let choices = createVoteView.choiceTextFields.compactMap { $0.text }.filter { !$0.isEmpty }

        // Validate the title and choices
        guard !title.isEmpty else {
            showAlert(message: "Vote title cannot be empty.")
            return
        }

        guard choices.count >= 2 else {
            showAlert(message: "At least two choices are required.")
            return
        }

        print("Publishing vote with title: \(title) and choices: \(choices)")
        // Handle data transfer here (to be implemented later)

        // Return to the previous screen
        navigationController?.popViewController(animated: true)
    }

    // Helper method to show an alert
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
