//
//  AddANewTravelViewController.swift
//  Packsync
//
//  Created by Xi Jia on 11/7/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class AddANewTravelViewController: UIViewController {
    
    var currentUser:FirebaseAuth.User?
    
    let db = Firestore.firestore()
    
    let addANewTravelPlan = AddANewTravelPlanView()
    
    override func loadView(){
        view = addANewTravelPlan
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add a new travel plan"
        
        // Set the current user
        currentUser = Auth.auth().currentUser
        
        addANewTravelPlan.buttonAdd.addTarget(self, action: #selector(onAddButtonTapped), for: .touchUpInside)
    
    }

    @objc func onAddButtonTapped() {
        guard let currentUser = currentUser, let creatorEmail = currentUser.email else {
            showAlert(message: "User not logged in")
            return
        }
        
        guard let travelTitle = addANewTravelPlan.textFieldTravelTitle.text,
              let travelStartDate = addANewTravelPlan.textFieldTravelStartDate.text,
              let travelEndDate = addANewTravelPlan.textFieldTravelEndDate.text,
              let travelCountryAndCity = addANewTravelPlan.textFieldCountryAndCity.text,
              !travelTitle.isEmpty, !travelStartDate.isEmpty, !travelEndDate.isEmpty, !travelCountryAndCity.isEmpty else {
            showAlert(message: "Please fill in all fields")
            return
        }

        let travel = Travel(
            creatorEmail: creatorEmail,
            travelTitle: travelTitle,
            travelStartDate: travelStartDate,
            travelEndDate: travelEndDate,
            countryAndCity: travelCountryAndCity
        )
        
        saveTravelToFirestore(travel: travel)
    }

    func saveTravelToFirestore(travel: Travel) {
   
        let collectionTravelPlans = db.collection("travelPlans")
        
        do {
            try collectionTravelPlans.addDocument(from: travel) { error in
                if let error = error {
                    print("Error adding document: \(error.localizedDescription)")
                    self.showAlert(message: "Failed to save travel plan. Please try again.")
                } else {
                    print("Document added successfully")
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } catch {
            print("Error encoding travel data: \(error.localizedDescription)")
            self.showAlert(message: "Failed to save travel plan. Please try again.")
        }
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}
