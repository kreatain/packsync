//
//  TravelListViewController.swift
//  Packsync
//
//  Created by Xi Jia on 11/7/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth


class TravelViewController: UIViewController {
    
    let travelView = TravelView()
    
    var travelPlanList = [Travel]()
    
//    var listener: ListenerRegistration?
    
    let database = Firestore.firestore()
    
    // create an authentication state change listener to track whether any user is signed in
    var handleAuth: AuthStateDidChangeListenerHandle?
    
    // create a variable to keep an instance of the current signed-in Firebase user
    var currentUser:FirebaseAuth.User?

    
    override func loadView() {
        view = travelView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Travel Plans"
        view.backgroundColor = .white
        
        //MARK: patching table view delegate and data source...
        travelView.tableViewTravelPlans.dataSource = self
        travelView.tableViewTravelPlans.delegate = self
        
        //MARK: removing the separator line...
        travelView.tableViewTravelPlans.separatorStyle = .none
        
        // Add A New Traver button navigation to the AddANewTraverl Screen
//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTravelButtonTapped))
        
        travelView.buttonAddTravelPlan.addTarget(self, action: #selector(addTravelButtonTapped), for: .touchUpInside)
        
        
        fetchTravelPlans()
        
        // Add auth state listener
          Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
              self?.handleAuthStateChange(user: user)
          }
    
    }
    
    @objc func addTravelButtonTapped() {
        let addTravelViewController = AddANewTravelViewController()
        navigationController?.pushViewController(addTravelViewController, animated: true)
    }

    // a lifecycle method where you can handle the logic before the screen is loaded.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchTravelPlans()
        //MARK: handling if the Authentication state is changed (sign in, sign out, register)...
        handleAuth = Auth.auth().addStateDidChangeListener{ auth, user in
            if user == nil{
                //MARK: not signed in...
                self.currentUser = nil
                self.travelView.labelText.text = "Welcome to TravelCrew! Please Sign In"

                
                //MARK: Reset tableView...
                
                //MARK: Sign in bar button...
                self.setupLeftBarButton(isLoggedin: false)

            }else{
                //MARK: the user is signed in...
                self.currentUser = user
                self.travelView.labelText.text = "Welcome \(user?.displayName ?? "Anonymous")!"

                //MARK: Logout bar button...
                self.setupLeftBarButton(isLoggedin: true)
            }
        }
    }
    
    // is another lifecycle method where you can handle the logic right before the screen disappears.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handleAuth!)
    }

    func fetchTravelPlans(){
        database.collection("travelPlans").getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                self?.travelPlanList = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Travel.self)
                } ?? []
                
                // Sort the travelPlans array by travelStartDate
                self?.travelPlanList.sort { (travel1, travel2) -> Bool in
                    guard let date1 = self?.dateFromString(travel1.travelStartDate),
                          let date2 = self?.dateFromString(travel2.travelStartDate) else {
                        return false
                    }
                    return date1 < date2
                }
                
                DispatchQueue.main.async {
                    self?.travelView.tableViewTravelPlans.reloadData()
                }
            }
        }
    }

    // Helper method to convert string to Date
    func dateFromString(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm" // Adjust this format to match your date string format
        return dateFormatter.date(from: dateString)
    }
    
    func handleLogout() {
        do {
            try Auth.auth().signOut()
            // Clear the travel plans data
            travelPlanList.removeAll()
            // Reload the table view to reflect the empty data
            travelView.tableViewTravelPlans.reloadData()
            // Hide the table view
            travelView.tableViewTravelPlans.isHidden = true
            // Show a message or a login button
            showLoginPrompt()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    func showLoginPrompt() {
        // Create and configure a login button or message
        let loginButton = UIButton(type: .system)
        loginButton.setTitle("Login", for: .normal)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        travelView.addSubview(loginButton)
        
        NSLayoutConstraint.activate([
            loginButton.centerXAnchor.constraint(equalTo: travelView.centerXAnchor),
            loginButton.centerYAnchor.constraint(equalTo: travelView.centerYAnchor)
        ])
    }

    @objc func loginButtonTapped() {
        // Navigate to login screen or present login view controller
        // This depends on your app's navigation structure
    }
    
    func handleAuthStateChange(user: FirebaseAuth.User?) {
        setupLeftBarButton(isLoggedin: user != nil)
        if let user = user {
            // User is logged in
            fetchTravelPlans()
            travelView.tableViewTravelPlans.isHidden = false
            travelView.buttonAddTravelPlan.isHidden = false
            travelView.labelText.isHidden = true
        } else {
            // User is logged out
            travelPlanList.removeAll()
            travelView.tableViewTravelPlans.reloadData()
            travelView.tableViewTravelPlans.isHidden = true
            travelView.buttonAddTravelPlan.isHidden = true
            travelView.labelText.isHidden = false
            travelView.labelText.text = "Please sign in to view your travel plans."
        }
    }

}
        

