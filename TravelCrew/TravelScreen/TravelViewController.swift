
import UIKit
import FirebaseFirestore
import FirebaseAuth

class TravelViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TravelViewDelegate, TravelPlanTableViewCellDelegate {
    
    // Properties
    let travelView = TravelView()
    var travelPlanList = [Travel]()
    let database = Firestore.firestore()
    var handleAuth: AuthStateDidChangeListenerHandle?
    var currentUser: FirebaseAuth.User?
    
    // Load the custom view
    override func loadView() {
        view = travelView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Travel Plans"
        view.backgroundColor = .white
        
        navigationItem.largeTitleDisplayMode = .always
        
        // Set delegate for TravelView and TableView
        travelView.delegate = self
        travelView.tableViewTravelPlans.dataSource = self
        travelView.tableViewTravelPlans.delegate = self
        travelView.tableViewTravelPlans.separatorStyle = .none
        updateLoginPromptVisibility()
        // Add target for the "Add Travel Plan" button at the bottom
        travelView.buttonAddTravelPlan.addTarget(self, action: #selector(addTravelButtonTapped), for: .touchUpInside)
        
        // Set up the log in/out button on the left bar
        setupLeftBarButton(isLoggedin: Auth.auth().currentUser != nil)
        
        // Add authentication state change listener
        handleAuth = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            self?.handleAuthStateChange(user: user)
        }
        if let activePlan = loadActivePlanLocally() {
            TravelPlanManager.shared.setActiveTravelPlan(activePlan)
            updateActivePlanDetailView(with: activePlan)
        } else {
            didTapActivePlanButton() // Default to placeholder message if no active plan
        }
        if Auth.auth().currentUser != nil {
                travelView.loginPromptLabel.isHidden = true
            } else {
                travelView.loginPromptLabel.isHidden = false
            }

        DispatchQueue.main.async {
            self.travelView.otherPlansButton.sendActions(for: .touchUpInside)
            self.travelView.activePlanButton.sendActions(for: .touchUpInside)
        }
        
        // Add observer for active travel plan changes
        NotificationCenter.default.addObserver(self, selector: #selector(handleActivePlanChange), name: .activeTravelPlanChanged, object: nil)
       
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .activeTravelPlanChanged, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateLoginPromptVisibility()
        // Ensure the correct tab is displayed when redirected
        DispatchQueue.main.async {
            self.travelView.otherPlansButton.sendActions(for: .touchUpInside)
            
            self.travelView.activePlanButton.sendActions(for: .touchUpInside)
        }

    }
    
    func updateLoginPromptVisibility() {
        if Auth.auth().currentUser == nil {
            
            travelView.loginPromptLabel.isHidden = false
            travelView.tableViewTravelPlans.isHidden = true
            travelView.buttonAddTravelPlan.isHidden = true
            travelView.activePlanDetailView.isHidden = true
            travelView.activePlanButton.isHidden = true
            travelView.otherPlansButton.isHidden = true
            travelView.segmentedControlView.isHidden = true
        } else {
    
            travelView.loginPromptLabel.isHidden = true
            travelView.tableViewTravelPlans.isHidden = false
            travelView.buttonAddTravelPlan.isHidden = false
            travelView.activePlanButton.isHidden = false
            travelView.otherPlansButton.isHidden = false
            travelView.segmentedControlView.isHidden = false
                    
            if let activePlan = TravelPlanManager.shared.activeTravelPlan {
                updateActivePlanDetailView(with: activePlan)
                travelView.activePlanDetailView.isHidden = false
            } else {
                travelView.activePlanDetailView.isHidden = true
            }
        }
    }
   
    func fetchTravelPlans() {
            guard let userId = Auth.auth().currentUser?.uid else {
                print("User is not signed in.")
                return
            }
            print("Current User ID: \(userId)") // For debugging

            // Reset travelPlanList to avoid residual data
            travelPlanList = []

            database.collection("travelPlans")
                .whereField("participantIds", arrayContains: userId)
                .addSnapshotListener { [weak self] (querySnapshot, error) in
                    if let error = error {
                        print("Error fetching travel plans: \(error)")
                        return
                    }

                    self?.travelPlanList = querySnapshot?.documents.compactMap { document in
                        try? document.data(as: Travel.self)
                    } ?? []

                    DispatchQueue.main.async {
                        print("Reloading travel plans table with \(self?.travelPlanList.count ?? 0) plans.")
                        self?.travelView.tableViewTravelPlans.reloadData()
                        self?.updateActivePlanIfNeeded()
                    }
                }
        }
    
    private func updateActivePlanIfNeeded() {
        if let activePlan = TravelPlanManager.shared.activeTravelPlan,
           let updatedPlan = travelPlanList.first(where: { $0.id == activePlan.id }) {
            TravelPlanManager.shared.setActiveTravelPlan(updatedPlan)
            updateActivePlanDetailView(with: updatedPlan)
        }
    }
    
    // MARK: - Handle Active Plan Change
    @objc func handleActivePlanChange() {
        if let activePlan = TravelPlanManager.shared.activeTravelPlan {
            updateActivePlanDetailView(with: activePlan)
            // Hide the placeholder message
            travelView.activePlanLabel.isHidden = true
        } else {
            displayNoActivePlanMessage()
            // Hide the active plan details view
            clearActivePlanDetailView()
        }
    }
    
    // MARK: - Display Placeholder for No Active Plan
    
   
    private func displayNoActivePlanMessage() {
        travelView.activePlanTitleLabel.text = "No active plan set."
        travelView.activePlanDateLabel.text = "Go to 'Other Plans' to set an active plan."
        travelView.activePlanLocationLabel.text = "Swipe left to set."
        travelView.activePlanDetailView.isHidden = false
        travelView.tableViewTravelPlans.isHidden = true

            // Force layout update
        view.layoutIfNeeded()
    }
    // MARK: - Update Active Plan Detail View

    func updateActivePlanDetailView(with activePlan: Travel) {
        travelView.activePlanTitleLabel.text = "Title: \(activePlan.travelTitle)"
        travelView.activePlanDateLabel.text = "Date: \(activePlan.travelStartDate) - \(activePlan.travelEndDate)"
        travelView.activePlanLocationLabel.text = "Location: \(activePlan.countryAndCity)"
        travelView.activePlanParticipantIdsLabel.text = "Participants: \(activePlan.participantNames.joined(separator: ", "))"

        travelView.activePlanDescriptionLabel.text = "Please tap the bottom navigation bar to explore more about the active plan!"
    }
    
    // MARK: - Clear Active Plan Detail View
    private func clearActivePlanDetailView() {
        travelView.activePlanTitleLabel.text = ""
        travelView.activePlanDateLabel.text = ""
        travelView.activePlanLocationLabel.text = ""
        travelView.activePlanParticipantIdsLabel.text = ""
        travelView.activePlanDescriptionLabel.text = ""
        travelView.activePlanDetailView.isHidden = true
    }
    private func loadActivePlanLocally() -> Travel? {
        if let savedData = UserDefaults.standard.data(forKey: "activePlanData") {
            let decoder = JSONDecoder()
            if let savedPlan = try? decoder.decode(Travel.self, from: savedData) {
                print("Active plan loaded from local storage.")
                return savedPlan
            }
        }
        print("No active plan found in local storage.")
        return nil
    }
    // MARK: - TravelViewDelegate Methods

    func didTapActivePlanButton() {
        guard Auth.auth().currentUser != nil else {
                print("User not logged in, hiding active plan details.")
                return
            }

        travelView.activePlanButton.backgroundColor = .systemBlue
        travelView.activePlanButton.setTitleColor(.white, for: .normal)
        travelView.otherPlansButton.backgroundColor = .clear
        travelView.otherPlansButton.setTitleColor(.systemBlue, for: .normal)
        
        guard Auth.auth().currentUser != nil else {
                print("User is not logged in. Hiding active plan detail view.")
                travelView.activePlanDetailView.isHidden = true
                travelView.loginPromptLabel.isHidden = false
                travelView.activePlanLabel.isHidden = true
                return
            }


        travelView.loginPromptLabel.isHidden = true
        if let activePlan = TravelPlanManager.shared.activeTravelPlan {
            updateActivePlanDetailView(with: activePlan)
            travelView.activePlanDetailView.isHidden = false
            travelView.tableViewTravelPlans.isHidden = true
        } else {
            displayNoActivePlanMessage()
            
        }

        view.layoutIfNeeded()
    }
    
    func didTapOtherPlansButton() {
        guard Auth.auth().currentUser != nil else {
                print("User not logged in, hiding all plans.")
                return
            }

        travelView.otherPlansButton.backgroundColor = .systemBlue
        travelView.otherPlansButton.setTitleColor(.white, for: .normal)
        travelView.activePlanButton.backgroundColor = .clear
        travelView.activePlanButton.setTitleColor(.systemBlue, for: .normal)

        guard Auth.auth().currentUser != nil else {
                travelView.loginPromptLabel.isHidden = false
                travelView.tableViewTravelPlans.isHidden = true
                return
            }

        travelView.loginPromptLabel.isHidden = true
        // Show only the list view of all plans and hide the active plan view
        travelView.tableViewTravelPlans.isHidden = false
        travelView.activePlanDetailView.isHidden = true
        
        // Fetch and reload all plans into the list view
        fetchTravelPlans()
    }
    
    // MARK: - TravelPlanTableViewCellDelegate Methods
    
    func setActivePlanButtonTapped(_ travelPlan: Travel) {
        print("Set Active tapped for: \(travelPlan.travelTitle)")

        // Set the active travel plan
        TravelPlanManager.shared.setActiveTravelPlan(travelPlan)

        // Save the active plan data locally
        saveActivePlanLocally(travelPlan)

        // Notify other parts of the app about the active plan change
        NotificationCenter.default.post(name: .activeTravelPlanChanged, object: nil)

        travelView.tableViewTravelPlans.reloadData()
        didTapActivePlanButton()
    }
    
    private func saveActivePlanLocally(_ travelPlan: Travel) {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(travelPlan) {
            UserDefaults.standard.set(encodedData, forKey: "activePlanData")
            print("Active plan saved locally.")
        }
    }
    func editTravelPlanTapped(_ travelPlan: Travel) {
        print("Edit tapped for: \(travelPlan.travelTitle)")
    }
    
    func deleteTravelPlanTapped(_ travelPlan: Travel) {
        let alert = UIAlertController(title: "Delete Travel Plan", message: "Are you sure you want to delete this travel plan?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteTravel(travelPlan)
        })
        present(alert, animated: true, completion: nil)
    }
    
    func deleteTravel(_ travelPlan: Travel) {
        database.collection("travelPlans").document(travelPlan.id).delete { error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
                self.travelPlanList.removeAll { $0.id == travelPlan.id }
                self.travelView.tableViewTravelPlans.reloadData()
            }
        }
    }
    
    @objc func addTravelButtonTapped() {
        let addTravelViewController = AddANewTravelViewController()
        navigationController?.pushViewController(addTravelViewController, animated: true)
    }

    
    func handleAuthStateChange(user: FirebaseAuth.User?) {
        if let user = user {
            currentUser = user
            fetchTravelPlans()

            updateLoginPromptVisibility()
   
            travelView.loginPromptLabel.isHidden = true
            travelView.tableViewTravelPlans.isHidden = false
            travelView.buttonAddTravelPlan.isHidden = false

            if let activePlan = TravelPlanManager.shared.activeTravelPlan {
                updateActivePlanDetailView(with: activePlan)
                travelView.activePlanDetailView.isHidden = false
            } else {
                travelView.activePlanDetailView.isHidden = true
            }

            setupLeftBarButton(isLoggedin: true)
            DispatchQueue.main.async {
                self.travelView.activePlanButton.sendActions(for: .touchUpInside)
            }
        } else {
            currentUser = nil
            travelPlanList.removeAll()
            travelView.tableViewTravelPlans.reloadData()

   
            travelView.loginPromptLabel.isHidden = false
            travelView.tableViewTravelPlans.isHidden = true
            travelView.buttonAddTravelPlan.isHidden = true
            clearActivePlanDetailView()
            travelView.activePlanDetailView.isHidden = true

            updateLoginPromptVisibility()
            setupLeftBarButton(isLoggedin: false)
        }
    }
    
    // MARK: - Swipe Actions for TableView
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let travelPlan = travelPlanList[indexPath.row]
        
        // Edit Action
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, completionHandler) in
            self?.editTravelPlanTapped(travelPlan)
            completionHandler(true)
        }
        editAction.backgroundColor = .systemBlue
        
        // Delete Action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            self?.deleteTravelPlanTapped(travelPlan)
            completionHandler(true)
        }
        
        // Conditional Set Active/Deactivate Action
        let isActivePlan = TravelPlanManager.shared.activeTravelPlan?.id == travelPlan.id
        let activeTitle = isActivePlan ? "Deactivate" : "Set Active"
        let setActiveAction = UIContextualAction(style: .normal, title: activeTitle) { [weak self] (action, view, completionHandler) in
            if isActivePlan {
                // Deactivate and switch to "Active Plan" tab
                TravelPlanManager.shared.clearActiveTravelPlan()
                self?.didTapActivePlanButton() // Immediately switch to Active Plan tab
            } else {
                // Set as active and switch to "Active Plan" tab
                self?.setActivePlanButtonTapped(travelPlan)
                self?.didTapActivePlanButton() // Immediately switch to Active Plan tab
            }
            completionHandler(true)
        }
        setActiveAction.backgroundColor = .systemGreen
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction, setActiveAction])
    }
}

// MARK: - UITableViewDataSource
extension TravelViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of rows in table: \(travelPlanList.count)")
        return travelPlanList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Configs.tableViewTravelPlansID, for: indexPath) as! TravelPlanTableViewCell
        let travelPlan = travelPlanList[indexPath.row]
        cell.configure(with: travelPlan)
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TravelViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let travelPlan = travelPlanList[indexPath.row]
        
        // Initialize the detail view controller and pass the selected travel plan
        let travelDetailVC = TravelDetailViewController()
        travelDetailVC.travel = travelPlan
        print("travel view travle id: \(travelPlan.id)")
        // Navigate to the detail view controller
        navigationController?.pushViewController(travelDetailVC, animated: true)
    }
}
