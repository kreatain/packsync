//
//  TravelListViewController.swift
//  Packsync
//
//  Created by 许多 on 10/24/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth


class TravelViewController: UIViewController {
    
    let travelView = TravelView()
    
    var travelPlanList = [Travel]()
    
    var listener: ListenerRegistration?
    
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
        
        title = "TravelCrew"
        view.backgroundColor = .white
        
        //MARK: patching table view delegate and data source...
        travelView.tableViewTravelPlans.dataSource = self
        travelView.tableViewTravelPlans.delegate = self
        
        //MARK: removing the separator line...
        travelView.tableViewTravelPlans.separatorStyle = .none
        
        // Add A New Traver button navigation to the AddANewTraverl Screen
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTravelButtonTapped))
        
        fetchTravelPlans()
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
                self.travelView.labelText1.text = "Welcome to TravelCrew! Please Sign In"

                
                //MARK: Reset tableView...
                
                //MARK: Sign in bar button...
                self.setupLeftBarButton(isLoggedin: false)

            }else{
                //MARK: the user is signed in...
                self.currentUser = user
                self.travelView.labelText1.text = "Welcome \(user?.displayName ?? "Anonymous")!"

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
    
    func fetchTravelPlans() {
        database.collection("travelPlans").getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                self?.travelPlanList = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Travel.self)
                } ?? []
                DispatchQueue.main.async {
                    self?.travelView.tableViewTravelPlans.reloadData()
                }
            }
        }
    }

}
