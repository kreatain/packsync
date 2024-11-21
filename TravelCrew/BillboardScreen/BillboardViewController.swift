import UIKit
import FirebaseFirestore
import FirebaseAuth
import PhotosUI
import FirebaseStorage

class BillboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    // Properties
    private let billboardView = BillboardView()
    private var notices: [Billboard] = [] // Data source for the table view
    private var userNames: [String: String] = [:] // Dictionary to map authorId to displayName
    private var listener: ListenerRegistration?
    override func loadView() {
        view = billboardView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupRealTimeListener()
    }
    
    deinit {
            listener?.remove()
            print("Real-time listener removed.")
    }

    // Setup the view controller
    private func setupViewController() {
        title = "Billboard"
        view.backgroundColor = .white

        // Set delegates
        billboardView.tableView.dataSource = self
        billboardView.tableView.delegate = self
        billboardView.inputTextField.delegate = self
        billboardView.tableView.register(BillboardCell.self, forCellReuseIdentifier: "BillboardCell")
        billboardView.tableView.separatorStyle = .none
        billboardView.tableView.rowHeight = UITableView.automaticDimension
        billboardView.tableView.estimatedRowHeight = 100

        // Add actions for buttons
        billboardView.plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        billboardView.sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
    }
    
    private func setupRealTimeListener() {
        guard let activeTravelId = TravelPlanManager.shared.activeTravelPlan?.id else {
            print("No active travel plan found.")
            return
        }

        let db = Firestore.firestore()

        // Listen for changes to "notice", "vote", and "photo" types
        listener = db.collection("billboards")
            .whereField("travelId", isEqualTo: activeTravelId)
            .whereField("type", in: ["notice", "vote", "photo"]) // Include "photo" type
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                if let error = error {
                    print("Error listening for real-time updates: \(error.localizedDescription)")
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    print("No documents found.")
                    return
                }

                print("Real-time listener triggered. Documents count: \(documents.count)")

                // Parse the notices, votes, and photos
                self?.notices = documents.compactMap { document in
                    try? document.data(as: Billboard.self)
                }

                // Reload the table view on the main thread
                DispatchQueue.main.async {
                    self?.fetchUserNames()
                    self?.billboardView.tableView.reloadData()
                }
            }
    }
    
    
    private func fetchUserNames() {
        let db = Firestore.firestore()
        let authorIds = Set(notices.map { $0.authorId })

        for authorId in authorIds {
            if userNames[authorId] != nil {
                continue
            }

            db.collection("users").document(authorId).getDocument { [weak self] (document, error) in
                if let error = error {
                    print("Error fetching user data: \(error.localizedDescription)")
                    return
                }

                if let document = document, document.exists {
                    print("Fetched user data: \(document.data() ?? [:])")
                    let displayName = document.data()?["displayName"] as? String ?? "Unknown"
                    self?.userNames[authorId] = displayName

                    // Reload the table view after fetching each user name
                    DispatchQueue.main.async {
                        self?.billboardView.tableView.reloadData()
                        print("Table view reloaded after fetching user name.")
                    }
                }
            }
        }
    }
    
    private func fetchNotices() {
        guard let activeTravelId = TravelPlanManager.shared.activeTravelPlan?.id else {
            print("No active travel plan found.")
            return
        }

        let db = Firestore.firestore()
        db.collection("billboards")
            .whereField("travelId", isEqualTo: activeTravelId)
            .whereField("type", isEqualTo: "notice")
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] (querySnapshot, error) in
                if let error = error {
                    print("Error fetching notices: \(error.localizedDescription)")
                    return
                }

                // Parse the notices and fetch user display names
                self?.notices = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Billboard.self)
                } ?? []

                // Fetch user display names for all authorIds
                self?.fetchUserNames()
            }
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
    
    @objc private func sendButtonTapped() {
        // Check if the input message is empty
        guard let message = billboardView.inputTextField.text, !message.isEmpty else {
            print("Message is empty. Ignoring send action.")
            return
        }

        // Get the active travel plan ID
        guard let travelId = TravelPlanManager.shared.activeTravelPlan?.id else {
            print("No active travel plan found.")
            return
        }

        // Get the current user's ID
        guard let authorId = Auth.auth().currentUser?.uid else {
            print("User is not authenticated.")
            return
        }

        // Create a new Billboard object for the notice
        let billboardId = UUID().uuidString
        let notice = Billboard(
            id: billboardId,
            travelId: travelId,
            type: "notice",
            content: message,
            createdAt: Date(),
            authorId: authorId
        )

        // Send the notice to Firestore
        addNoticeToFirestore(notice)

        // Clear the input field after sending
        billboardView.inputTextField.text = ""
    }
    
    private func addNoticeToFirestore(_ notice: Billboard) {
        let db = Firestore.firestore()
        let documentId = notice.id ?? UUID().uuidString

        do {
            try db.collection("billboards").document(documentId).setData(from: notice)
            print("Notice added successfully!")

            // Manually trigger UI update (fallback in case real-time listener fails)
            DispatchQueue.main.async {
                self.fetchUserNames()
            }
        } catch let error {
            print("Error adding notice: \(error.localizedDescription)")
        }
    }
    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BillboardCell", for: indexPath) as? BillboardCell else {
            return UITableViewCell()
        }

        guard indexPath.row < notices.count else {
            print("Index out of range. Row: \(indexPath.row), Count: \(notices.count)")
            return UITableViewCell()
        }
        let item = notices[indexPath.row]
        let authorName = userNames[item.authorId] ?? "Unknown"
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let dateText = dateFormatter.string(from: item.createdAt)
        let authorText = "\(authorName)  \(dateText)"

        
        if item.type == "notice" {
            let content = item.content ?? "No content available."
            cell.configureNotice(title: "Notice", authorText: authorText, content: content)
        } else if item.type == "vote" {
            let choices = item.choices ?? []
            let votes = item.votes ?? [:]
            cell.configureVote(
                title: item.title ?? "No title",
                authorText: authorText,
                choices: choices,
                votes: votes,
                voteId: item.id ?? "",
                choiceSelectedHandler: { selectedChoice in
                    self.handleChoiceSelection(billboardId: item.id ?? "", selectedChoice: selectedChoice)
                }
            )
        } else if item.type == "photo" {
            if let photoUrl = item.photoUrl {
                cell.configurePhoto(title: "Photo", authorText: authorText, photoUrl: photoUrl)
                cell.layoutIfNeeded()
            }
        }

        return cell
    }
    
    private func handleChoiceSelection(billboardId: String, selectedChoice: String) {
        let db = Firestore.firestore()
        let documentRef = db.collection("billboards").document(billboardId)

        // Increment the vote count for the selected choice
        documentRef.updateData([
            "votes.\(selectedChoice)": FieldValue.increment(Int64(1))
        ]) { [weak self] error in
            if let error = error {
                print("Error updating vote: \(error.localizedDescription)")
            } else {
                print("Vote for '\(selectedChoice)' updated successfully!")
                self?.fetchNotices() // Refresh the table view after vote update
            }
        }
    }
    

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected row at index \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}


extension BillboardViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private func uploadPhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }

    // Image picker delegate method
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)

        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("No image selected.")
            return
        }

        // Upload image to Firebase Storage
        uploadImageToFirebase(image: selectedImage)
    }

    private func uploadImageToFirebase(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let storageRef = Storage.storage().reference().child("billboard_photos/\(UUID().uuidString).jpg")

        storageRef.putData(imageData, metadata: nil) { [weak self] (metadata, error) in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                return
            }

            storageRef.downloadURL { (url, error) in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    return
                }

                guard let downloadURL = url?.absoluteString else { return }
                print("Image uploaded successfully. URL: \(downloadURL)")
                self?.addPhotoNoticeToFirestore(photoUrl: downloadURL)
            }
        }
    }

    private func addPhotoNoticeToFirestore(photoUrl: String) {
        guard let travelId = TravelPlanManager.shared.activeTravelPlan?.id else {
            print("No active travel plan found.")
            return
        }
        guard let authorId = Auth.auth().currentUser?.uid else {
            print("User is not authenticated.")
            return
        }

        let billboardId = UUID().uuidString
        let notice = Billboard(
            id: billboardId,
            travelId: travelId,
            type: "photo",
            content: nil,
            photoUrl: photoUrl, createdAt: Date(),
            authorId: authorId
        )

        addNoticeToFirestore(notice)
    }
}
