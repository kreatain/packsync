import UIKit
import FirebaseFirestore
import FirebaseAuth

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

        print("Setting up real-time listener for travelId: \(activeTravelId)")

        let db = Firestore.firestore()
        listener = db.collection("billboards")
            .whereField("travelId", isEqualTo: activeTravelId)
            .whereField("type", isEqualTo: "notice")
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

                // Parse the notices
                self?.notices = documents.compactMap { document in
                    try? document.data(as: Billboard.self)
                }

                // Fetch user display names and reload the table view
                DispatchQueue.main.async {
                    self?.fetchUserNames()
                    self?.billboardView.tableView.reloadData()
                    print("Table view reloaded after real-time update.")
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
    private func uploadPhoto() {
        
    }
    
    private func navigateToCreateVote() {
        let createVoteVC = CreateVoteViewController()
        navigationController?.pushViewController(createVoteVC, animated: true)
    }

    @objc private func sendButtonTapped() {
        guard let message = billboardView.inputTextField.text, !message.isEmpty else {
            print("Message is empty.")
            return
        }

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
            type: "notice",
            content: message,
            createdAt: Date(),
            authorId: authorId
        )

        addNoticeToFirestore(notice)
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

        let notice = notices[indexPath.row]
        let authorName = userNames[notice.authorId] ?? "Unknown"

        // Format date text
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let dateText = dateFormatter.string(from: notice.createdAt)

        // Create author and date text: "[Author Name] [Date]"
        let authorAndDateText = "\(authorName) \(dateText)"

        // Configure the cell
        cell.configure(noticeTitle: "Notice", authorAndDate: authorAndDateText, content: notice.content ?? "No content available")

        return cell
    }
    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected row at index \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
