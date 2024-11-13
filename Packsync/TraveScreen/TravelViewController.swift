//
//  TravelListViewController.swift
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
    
    // View did load lifecycle method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Travel Plans"
        view.backgroundColor = .white
        
        // Set delegate for TravelView and TableView
        travelView.delegate = self
        travelView.tableViewTravelPlans.dataSource = self
        travelView.tableViewTravelPlans.delegate = self
        travelView.tableViewTravelPlans.separatorStyle = .none
        
        // Add target for the "Add Travel Plan" button
        travelView.buttonAddTravelPlan.addTarget(self, action: #selector(addTravelButtonTapped), for: .touchUpInside)
        
        // Fetch travel plans from Firestore
        fetchTravelPlans()
        
        // Add authentication state change listener
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            self?.handleAuthStateChange(user: user)
        }
    }
    
    // Fetch travel plans from Firestore
    // MARK: - Fetch Travel Plans
    func fetchTravelPlans() {
        guard let email = currentUser?.email else {
            print("User is not signed in.")
            return
        }

        // Fetch travel plans where the creatorEmail matches the current user's email
        database.collection("travelPlans")
            .whereField("creatorEmail", isEqualTo: email)
            .getDocuments { [weak self] (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                    return
                }

                // Map the documents to Travel objects
                self?.travelPlanList = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Travel.self)
                } ?? []

                // Sort the travel plans by start date
                self?.travelPlanList.sort { (travel1, travel2) -> Bool in
                    guard let date1 = self?.dateFromString(travel1.travelStartDate),
                          let date2 = self?.dateFromString(travel2.travelStartDate) else {
                        return false
                    }
                    return date1 < date2
                }

                // Reload the table view on the main thread
                DispatchQueue.main.async {
                    self?.travelView.tableViewTravelPlans.reloadData()
                }
            }
    }
    
    // Helper method to convert date string to Date object
    func dateFromString(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm"
        return dateFormatter.date(from: dateString)
    }
    
    // Handle the "Add Travel Plan" button tap
    @objc func addTravelButtonTapped() {
        let addTravelViewController = AddANewTravelViewController()
        navigationController?.pushViewController(addTravelViewController, animated: true)
    }
    
    // Handle authentication state changes
    func handleAuthStateChange(user: FirebaseAuth.User?) {
        setupLeftBarButton(isLoggedin: user != nil)
        
        if let user = user {
            // User is logged in
            currentUser = user
            fetchTravelPlans()
            travelView.tableViewTravelPlans.isHidden = false
            travelView.buttonAddTravelPlan.isHidden = false
            travelView.labelText.isHidden = true
            travelView.labelText.text = "Welcome \(user.displayName ?? "User")!"
            
            // Update active plan details if there's an active plan
            if let activePlan = TravelPlanManager.shared.activeTravelPlan {
                updateActivePlanDetailView(with: activePlan)
            } else {
                clearActivePlanDetailView()
            }
            
        } else {
            // User is logged out
            currentUser = nil
            travelPlanList.removeAll()
            TravelPlanManager.shared.clearActiveTravelPlan()
            
            // Clear the content of active plan detail view
            clearActivePlanDetailView()
            
            travelView.tableViewTravelPlans.reloadData()
            travelView.tableViewTravelPlans.isHidden = true
            travelView.buttonAddTravelPlan.isHidden = true
            travelView.labelText.isHidden = false
            travelView.labelText.text = "Please sign in to view your travel plans."
        }
    }
    
    private func clearActivePlanDetailView() {
        travelView.activePlanTitleLabel.text = ""
        travelView.activePlanDateLabel.text = ""
        travelView.activePlanLocationLabel.text = ""
        travelView.activePlanDetailView.isHidden = true
    }
    
    // MARK: - Update Active Plan Detail View
    func updateActivePlanDetailView(with activePlan: Travel) {
        travelView.activePlanTitleLabel.text = "Title: \(activePlan.travelTitle)"
        travelView.activePlanDateLabel.text = "Date: \(activePlan.travelStartDate) - \(activePlan.travelEndDate)"
        travelView.activePlanLocationLabel.text = "Location: \(activePlan.countryAndCity)"
        travelView.activePlanDetailView.isHidden = false
    }
    
    func didTapActivePlanButton() {
        // Update button states
        travelView.activePlanButton.backgroundColor = .systemBlue
        travelView.activePlanButton.setTitleColor(.white, for: .normal)
        travelView.otherPlansButton.backgroundColor = .clear
        travelView.otherPlansButton.setTitleColor(.systemBlue, for: .normal)

        // Show active plan details, hide travel list
        travelView.activePlanDetailView.isHidden = false
        travelView.tableViewTravelPlans.isHidden = true

        // Update active plan details
        if let activePlan = TravelPlanManager.shared.activeTravelPlan {
            travelView.activePlanTitleLabel.text = "Title: \(activePlan.travelTitle)"
            travelView.activePlanDateLabel.text = "Date: \(activePlan.travelStartDate) - \(activePlan.travelEndDate)"
            travelView.activePlanLocationLabel.text = "Location: \(activePlan.countryAndCity)"
        }
    }

    func didTapOtherPlansButton() {
        // Update button states
        travelView.otherPlansButton.backgroundColor = .systemBlue
        travelView.otherPlansButton.setTitleColor(.white, for: .normal)
        travelView.activePlanButton.backgroundColor = .clear
        travelView.activePlanButton.setTitleColor(.systemBlue, for: .normal)

        // Show travel list, hide active plan details
        travelView.tableViewTravelPlans.isHidden = false
        travelView.activePlanDetailView.isHidden = true
    }
    
    // Set the active travel plan
    func setActivePlanButtonTapped(_ travelPlan: Travel) {
        TravelPlanManager.shared.setActiveTravelPlan(travelPlan)
        travelView.tableViewTravelPlans.reloadData()
        didTapActivePlanButton()
    }
}

// MARK: - UITableViewDataSource
extension TravelViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return travelPlanList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Configs.tableViewTravelPlansID, for: indexPath) as? TravelPlanTableViewCell else {
            return UITableViewCell()
        }
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
        setActivePlanButtonTapped(travelPlan)
    }
}
