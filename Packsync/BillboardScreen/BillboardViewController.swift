import UIKit

class BillboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    // Properties
    private let billboardView = BillboardView()

    override func loadView() {
        view = billboardView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
    }

    // Setup the view controller
    private func setupViewController() {
        title = "Billboard"
        view.backgroundColor = .white

        // Set delegates
        billboardView.tableView.dataSource = self
        billboardView.tableView.delegate = self
        billboardView.inputTextField.delegate = self

        // Add actions for buttons
        billboardView.plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        billboardView.sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
    }

    // "+" button action

    @objc private func plusButtonTapped() {
        let alert = UIAlertController(title: "Choose an Action", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Upload Photo", style: .default, handler: { _ in
            self.uploadPhoto()
        }))
        
        alert.addAction(UIAlertAction(title: "Create Vote", style: .default, handler: { _ in
            self.navigateToCreateVote()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func navigateToCreateVote() {
        let createVoteVC = CreateVoteViewController()
        navigationController?.pushViewController(createVoteVC, animated: true)
    }
    
    // "Send" button action
    @objc private func sendButtonTapped() {
        guard let message = billboardView.inputTextField.text, !message.isEmpty else {
            print("Message is empty.")
            return
        }

        print("Sending message: \(message)")
        // Here you can implement the logic to handle sending the message

        // Clear the input field after sending
        billboardView.inputTextField.text = ""
    }

    // Upload photo functionality (placeholder)
    private func uploadPhoto() {
        print("Upload photo action selected.")
        // Implement UIImagePickerController for photo selection here
    }

    // Create vote functionality (placeholder)
    private func createVote() {
        print("Create vote action selected.")
        // Implement vote creation UI here
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "BillboardCell")
        cell.textLabel?.text = "Sample Content"
        cell.detailTextLabel?.text = "Sample Detail"
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected row at index \(indexPath.row)")
    }
}
