//
//  TravelViewController.swift
//  Packsync
//
//  Created by Xi Jia on 11/7/24.
//

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
        
        // Set delegate for TravelView and TableView
        travelView.delegate = self
        travelView.tableViewTravelPlans.dataSource = self
        travelView.tableViewTravelPlans.delegate = self
        travelView.tableViewTravelPlans.separatorStyle = .none
        
        // Add target for the "Add Travel Plan" button at the bottom
        travelView.buttonAddTravelPlan.addTarget(self, action: #selector(addTravelButtonTapped), for: .touchUpInside)
        
        // Set up the log in/out button on the left bar
        setupLeftBarButton(isLoggedin: Auth.auth().currentUser != nil)
        
        // Add observer for active travel plan changes
        NotificationCenter.default.addObserver(self, selector: #selector(handleActivePlanChange), name: .activeTravelPlanChanged, object: nil)
        
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
        DispatchQueue.main.async {
            self.travelView.activePlanButton.sendActions(for: .touchUpInside)
        }
       
    }

    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .activeTravelPlanChanged, object: nil)
    }
 
    // MARK: - Fetch Travel Plans
        func fetchTravelPlans() {
            guard let userId = Auth.auth().currentUser?.uid else {
                print("User is not signed in.")
                return
            }
            
            print("Current User ID: \(userId)") // For debugging

            // Reset travelPlanList to avoid residual data
            travelPlanList = []
            
            database.collection("travelPlans")
                .whereField("participantIds", arrayContains: userId) // Query where participantIds includes current user ID
                .addSnapshotListener { [weak self] (querySnapshot, error) in
                    if let error = error {
                        print("Error fetching travel plans: \(error)")
                        return
                    }
                    
                    self?.travelPlanList = querySnapshot?.documents.compactMap { document in try? document.data(as: Travel.self) } ?? []
                    // Fetch participant display names after fetching travel plans
                    self?.fetchParticipantDisplayNames(for: self?.travelPlanList ?? [])
    
                    DispatchQueue.main.async {
                        print("Reloading travel plans table with \(self?.travelPlanList.count ?? 0) plans.")
                        self?.travelView.tableViewTravelPlans.reloadData()
                    }
                }
        }
    
    // MARK: - Fetch Participant Display Names
       func fetchParticipantDisplayNames(for travelPlans: [Travel]) {
           var participantIds = Set<String>()
           
           // Collect all unique participant IDs from travel plans
           for plan in travelPlans {
               participantIds.formUnion(plan.participantIds)
           }

           // Fetch display names for each participant ID
           var participantNamesDict = [String: String]()
           
           let group = DispatchGroup()
           
           for id in participantIds {
               group.enter()
               database.collection("users").document(id).getDocument { (document, error) in
                   if let document = document, document.exists,
                      let displayName = document.data()?["displayName"] as? String {
                       participantNamesDict[id] = displayName
                   }
                   group.leave()
               }
           }

           group.notify(queue: .main) {
               // Update travel plans with fetched names
               for i in 0..<travelPlans.count {
                   let plan = travelPlans[i]
                   let names = plan.participantIds.compactMap { participantNamesDict[$0] }
                   self.travelPlanList[i].participantIds = names // Update to use display names instead of IDs
               }
               
               DispatchQueue.main.async {
                   self.travelView.tableViewTravelPlans.reloadData()
               }
           }
       }
    
    // MARK: - Handle Active Plan Change
    @objc func handleActivePlanChange() {
        if let activePlan = TravelPlanManager.shared.activeTravelPlan {
            updateActivePlanDetailView(with: activePlan)
            // Hide the placeholder message
            travelView.labelText.isHidden = true
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
        
        // Display participant names instead of IDs
               travelView.activePlanParticipantIdsLabel.text = "Participants: \(activePlan.participantIds.joined(separator: ", "))"
        
        travelView.activePlanDetailView.isHidden = false // Ensure it's visible
    }
    
    // MARK: - Clear Active Plan Detail View
    private func clearActivePlanDetailView() {
        travelView.activePlanTitleLabel.text = ""
        travelView.activePlanDateLabel.text = ""
        travelView.activePlanLocationLabel.text = ""
        travelView.activePlanParticipantIdsLabel.text = ""
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
        print("Switched to Active Plan tab.")

        travelView.activePlanButton.backgroundColor = .systemBlue
        travelView.activePlanButton.setTitleColor(.white, for: .normal)
        travelView.otherPlansButton.backgroundColor = .clear
        travelView.otherPlansButton.setTitleColor(.systemBlue, for: .normal)

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
        print("Switched to All Plans tab.")

        travelView.otherPlansButton.backgroundColor = .systemBlue
        travelView.otherPlansButton.setTitleColor(.white, for: .normal)
        travelView.activePlanButton.backgroundColor = .clear
        travelView.activePlanButton.setTitleColor(.systemBlue, for: .normal)

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
            travelView.tableViewTravelPlans.isHidden = false
            travelView.buttonAddTravelPlan.isHidden = false
            setupLeftBarButton(isLoggedin: true)
        } else {
            currentUser = nil
            travelPlanList.removeAll()
            travelView.tableViewTravelPlans.reloadData()
            travelView.tableViewTravelPlans.isHidden = true
            travelView.buttonAddTravelPlan.isHidden = true
            travelView.labelText.isHidden = false
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
        
        // Navigate to the detail view controller
        navigationController?.pushViewController(travelDetailVC, animated: true)
    }
}
