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
    var travelId: String?
    private let noActivePlanLabel = UILabel()
    private var participantCounts: [String: Int] = [:]
    convenience init(travelId: String? = nil) {
            self.init()
            self.travelId = travelId
        }
    override func loadView() {
        view = billboardView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        if let travelId = travelId {
            preloadParticipantCount(for: travelId)
            setupRealTimeListener(using: travelId)
            hideNoActivePlanNotice()
        } else if let activeTravelId = TravelPlanManager.shared.activeTravelPlan?.id {
            preloadParticipantCount(for: activeTravelId)
            setupRealTimeListener(using: activeTravelId)
            hideNoActivePlanNotice()
        } else {
            print("No active travel plan found and no travelId provided.")
            showNoActivePlanNotice()
        }
        
        
        checkLoginStatus()
        setupNoActivePlanLabel()
        
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(activeTravelPlanDidChange),
                name: .activeTravelPlanChanged,
                object: nil
            )
    }
    
    
    deinit {
            listener?.remove()
            NotificationCenter.default.removeObserver(self)
            print("BillboardViewController deinitialized and listener removed.")
    }

    private func showNoTravelPlanAlert() {
            let alert = UIAlertController(title: "No Travel Plan", message: "Please select or create a travel plan to view the Billboard.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true)
        }
    
    private func checkLoginStatus() {
        if Auth.auth().currentUser == nil {
            showLoginPrompt()
        } else {
            if travelId == nil, TravelPlanManager.shared.activeTravelPlan?.id == nil {
                showNoActivePlanNotice()
            } else {
                hideNoActivePlanNotice()
                setupViewController()
                
                if let travelId = travelId {
                    preloadParticipantCount(for: travelId)
                    setupRealTimeListener(using: travelId)
                } else if let activeTravelId = TravelPlanManager.shared.activeTravelPlan?.id {
                    preloadParticipantCount(for: activeTravelId)
                    setupRealTimeListener(using: activeTravelId)
                } else {
                    showNoActivePlanNotice()
                }
            }
        }
    }
    
    private func showNoActivePlanNotice() {
        noActivePlanLabel.isHidden = false
        billboardView.tableView.isHidden = true
        billboardView.inputTextField.isHidden = true
        billboardView.plusButton.isHidden = true
        billboardView.sendButton.isHidden = true
    }
    
    private func hideNoActivePlanNotice() {
        noActivePlanLabel.isHidden = true
        billboardView.tableView.isHidden = false
        billboardView.inputTextField.isHidden = false
        billboardView.plusButton.isHidden = false
        billboardView.sendButton.isHidden = false
    }
    
    private func setupNoActivePlanLabel() {
        noActivePlanLabel.text = "Please select an active travel plan to view the Billboard."
        noActivePlanLabel.textAlignment = .center
        noActivePlanLabel.numberOfLines = 0
        noActivePlanLabel.textColor = .gray
        noActivePlanLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noActivePlanLabel)
        
        NSLayoutConstraint.activate([
            noActivePlanLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noActivePlanLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noActivePlanLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            noActivePlanLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        noActivePlanLabel.isHidden = true
    }
    
    private func showLoginPrompt() {
        // Show the login prompt
        billboardView.labelLoginPrompt.isHidden = false

        // Hide other UI elements
        billboardView.tableView.isHidden = true
        billboardView.inputTextField.isHidden = true
        billboardView.plusButton.isHidden = true
        billboardView.sendButton.isHidden = true
    }
    
    @objc private func activeTravelPlanDidChange() {
        if let activeTravelId = TravelPlanManager.shared.activeTravelPlan?.id {
            self.travelId = activeTravelId
            preloadParticipantCount(for: activeTravelId)
            setupRealTimeListener(using: activeTravelId)
            hideNoActivePlanNotice()
        } else {
            self.travelId = nil
            showNoActivePlanNotice()
        }
        updateTitle()
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
        
        updateTitle()
    }
    
   
    private func updateTitle() {
        print("updateTitle called. travelId: \(String(describing: travelId))")
        if let travelId = travelId {
            fetchTravelPlanTitle(for: travelId) { [weak self] title in
                DispatchQueue.main.async {
                    print("Setting navigationItem title to: \(title)")
                    self?.navigationItem.title = title
                }
            }
        } else if let activeTravelId = TravelPlanManager.shared.activeTravelPlan?.id {
            fetchTravelPlanTitle(for: activeTravelId) { [weak self] title in
                DispatchQueue.main.async {
                    print("Setting navigationItem title to: \(title)")
                    self?.navigationItem.title = title
                }
            }
        } else {
            print("No travelId or activeTravelId. Default title used.")
            self.navigationItem.title = "Billboard"
        }
    }
    
    private func fetchTravelPlanTitle(for travelId: String, completion: @escaping (String) -> Void) {
        let db = Firestore.firestore()
        db.collection("travelPlans").document(travelId).getDocument { document, error in
            if let error = error {
                print("Error fetching travel plan title: \(error.localizedDescription)")
                completion("Billboard") // Default title in case of an error
                return
            }

            if let document = document, let data = document.data(), let travelTitle = data["travelTitle"] as? String {
                completion(travelTitle)
            } else {
                completion("Billboard") // Default title if data is missing
            }
        }
    }
    
    private func setupRealTimeListener(using travelId: String) {
        let db = Firestore.firestore()
        listener = db.collection("billboards")
            .whereField("travelId", isEqualTo: travelId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                if let error = error {
                    print("Error listening for real-time updates: \(error.localizedDescription)")
                    return
                }
                guard let documents = querySnapshot?.documents else {
                    print("No documents found for travelId: \(travelId).")
                    return
                }

                print("Real-time listener triggered for travelId: \(travelId). Documents count: \(documents.count)")
                
                self?.notices = documents.compactMap { document in
                    try? document.data(as: Billboard.self)
                }
                
                // Fetch all user names for author IDs
                self?.fetchUserNames()
                
                DispatchQueue.main.async {
                    self?.billboardView.tableView.reloadData()
                }
            }
    }
    
    
    private func preloadParticipantCount(for travelId: String) {
        fetchTravelPlan(by: travelId) { [weak self] travelPlan in
            guard let self = self else { return }
            self.participantCounts[travelId] = travelPlan?.participantIds.count ?? 0
            DispatchQueue.main.async {
                self.billboardView.tableView.reloadData()
            }
        }
    }
    
    private func fetchUserNames() {
        let db = Firestore.firestore()

        let authorIds = Set(notices.map { $0.authorId })
        print("Author IDs to fetch:", authorIds)

        for authorId in authorIds where userNames[authorId] == nil {
            db.collection("users").document(authorId).getDocument { [weak self] (document, error) in
                if let error = error {
                    print("Error fetching user data for authorId \(authorId): \(error.localizedDescription)")
                    return
                }

                if let document = document, document.exists {
                    let displayName = document.data()?["displayName"] as? String ?? "Unknown"
                    self?.userNames[authorId] = displayName
                    print("Fetched userName for authorId \(authorId): \(displayName)")

                    DispatchQueue.main.async {
                        self?.billboardView.tableView.reloadData()
                    }
                } else {
                    print("User document for authorId \(authorId) not found.")
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
        let travelIdToPass = self.travelId ?? TravelPlanManager.shared.activeTravelPlan?.id
        
        guard let travelId = travelIdToPass else {
            showNoTravelPlanAlert()
            return
        }
        
        let createVoteVC = CreateVoteViewController(travelId: travelId)
        navigationController?.pushViewController(createVoteVC, animated: true)
    }
    
    private func fetchTravelPlan(by travelId: String, completion: @escaping (Travel?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("travelPlans").document(travelId).getDocument { (document, error) in
            if let error = error {
                print("Error fetching travel plan: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let document = document, document.exists, let travelPlan = try? document.data(as: Travel.self) else {
                print("No travel plan found for travelId: \(travelId)")
                completion(nil)
                return
            }
            
            completion(travelPlan)
        }
    }
    
    func fetchParticipantCount(for travelId: String?, completion: @escaping (Int) -> Void) {
        guard let travelId = travelId ?? TravelPlanManager.shared.activeTravelPlan?.id else {
            print("No travelId or activeTravelPlan available.")
            completion(0)
            return
        }
        
        fetchTravelPlan(by: travelId) { travelPlan in
            let participantCount = travelPlan?.participantIds.count ?? 0
            completion(participantCount)
        }
    }
    @objc private func sendButtonTapped() {
        // Check if the input message is empty
        guard let message = billboardView.inputTextField.text, !message.isEmpty else {
            print("Message is empty. Ignoring send action.")
            return
        }

        guard let travelId = self.travelId ?? TravelPlanManager.shared.activeTravelPlan?.id else {
            print("No travel ID available to send the notice.")
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
        // Dequeue the reusable cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BillboardCell", for: indexPath) as? BillboardCell else {
            return UITableViewCell()
        }

        // Safeguard against out-of-bounds errors
        guard indexPath.row < notices.count else {
            print("Index out of range. Row: \(indexPath.row), Count: \(notices.count)")
            return UITableViewCell()
        }

        let item = notices[indexPath.row] // Get the current notice
        let authorName = userNames[item.authorId] ?? "Unknown" // Author name
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let dateText = dateFormatter.string(from: item.createdAt)
        let authorText = "\(authorName)  \(dateText)" // Combine author name and date

        // Configure the cell based on the type of the notice
        if item.type == "notice" {
            // Configure for 'notice' type
            let content = item.content ?? "No content available."
            cell.configureNotice(title: "Notice", authorText: authorText, content: content)

        } else if item.type == "vote" {
            // Configure for 'vote' type
            let choices = item.choices ?? [] // Get the choices for the vote
            let votes = item.votes ?? [:] // Get the votes dictionary
            let nums = votes.values.reduce(0, +) // Total votes cast

            // Fetch participant count dynamically or use preloaded count
            let travelId = self.travelId ?? TravelPlanManager.shared.activeTravelPlan?.id
            let totalNums = participantCounts[travelId ?? ""] ?? 0// Use cached participant count
            
      
            
                    cell.configureVote(
                        title: item.title ?? "No title",
                        authorText: authorText,
                        choices: choices,
                        votes: votes,
                        voteId: item.id ?? "",
                        nums: nums, // Total votes cast
                        totalNums: totalNums, // Total participants
                        choiceSelectedHandler: { selectedChoice in
                            self.handleChoiceSelection(billboardId: item.id ?? "", selectedChoice: selectedChoice)
                        }
                    )
                
            

        } else if item.type == "photo" {
            // Configure for 'photo' type
            if let photoUrl = item.photoUrl {
                cell.configurePhoto(title: "Photo", authorText: authorText, photoUrl: photoUrl)
                cell.layoutIfNeeded() // Ensure the layout updates properly
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
        guard let travelId = self.travelId ?? TravelPlanManager.shared.activeTravelPlan?.id else {
                print("No travel ID available to add photo notice.")
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
// MARK: - UITableViewDelegate
extension BillboardViewController {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            self.deleteBillboard(at: indexPath)
            completionHandler(true)
        }
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    private func deleteBillboard(at indexPath: IndexPath) {
        // Safely retrieve the item to delete
        guard indexPath.row < notices.count else {
            print("Index out of range. Row: \(indexPath.row), Count: \(notices.count)")
            return
        }

        let billboardToDelete = notices[indexPath.row]
        guard let documentId = billboardToDelete.id else {
            print("Billboard ID is missing.")
            return
        }
        
        // Remove the item from the data source immediately to prevent the table from going out of sync
        notices.remove(at: indexPath.row)
        
        // Update the table view
        billboardView.tableView.deleteRows(at: [indexPath], with: .automatic)
        
        // Delete the item from Firestore
        let db = Firestore.firestore()
        db.collection("billboards").document(documentId).delete { [weak self] error in
            if let error = error {
                print("Error deleting billboard: \(error.localizedDescription)")
                
                // If Firestore deletion fails, re-add the item to the array and reload the table
                self?.notices.insert(billboardToDelete, at: indexPath.row)
                DispatchQueue.main.async {
                    self?.billboardView.tableView.reloadData()
                }
            } else {
                print("Billboard deleted successfully.")
            }
        }
    }
    
}
