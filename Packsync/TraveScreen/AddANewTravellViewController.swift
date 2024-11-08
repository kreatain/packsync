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
    
    let addANewTravelView = AddANewTravelView()
    
    override func loadView(){
        view = addANewTravelView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add a new travel plan"
        
        
        addANewTravelView.buttonAdd.addTarget(self, action: #selector(onAddButtonTapped), for: .touchUpInside)
    
    }
    

    
    //MARK: on add button tapped....
    @objc func onAddButtonTapped() {
//        let creatorEmail = currentUser?.email
        let travelTitle = addANewTravelView.textFieldTravelTitle.text
        let travelStartDate = addANewTravelView.textFieldTravelStartDate.text
        let travelEndDate = addANewTravelView.textFieldTravelEndDate.text
        let travelCountryAndCity = addANewTravelView.textFieldCountryAndCity.text

        if travelTitle == "" || travelStartDate == "" || travelEndDate == "" || travelCountryAndCity == "" {
            // Show an alert for empty fields
            showAlert(message: "Please fill in all fields")
        } else {
            let travel = Travel(
//                creatorEmail: creatorEmail!,
                travelTitle: travelTitle!,
                travelStartDate: travelStartDate!,
                travelEndDate: travelEndDate!,
                countryAndCity: travelCountryAndCity!
            )
            
            saveTravelToFirestore(travel: travel)
        }
    }

    func saveTravelToFirestore(travel: Travel) {
//        if let creatorEmail = currentUser!.email {
            let db = Firestore.firestore()
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
//        }
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}
