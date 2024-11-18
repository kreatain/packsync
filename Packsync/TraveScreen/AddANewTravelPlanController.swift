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
    
    var currentUser: FirebaseAuth.User?
    let db = Firestore.firestore()
    let addANewTravelPlan = AddANewTravelPlanView()
    
    // Currency options and selected currency
    let currencies = ["USD ($)", "EUR (€)", "GBP (£)", "JPY (¥)", "CNY (¥)", "INR (₹)"]
    var selectedCurrency: String?
    
    override func loadView() {
        view = addANewTravelPlan
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add a new travel plan"
        
        // Set the current user
        currentUser = Auth.auth().currentUser
        
        // Configure the picker
            addANewTravelPlan.currencyPicker.dataSource = self
            addANewTravelPlan.currencyPicker.delegate = self
            addANewTravelPlan.buttonAdd.addTarget(self, action: #selector(onAddButtonTapped), for: .touchUpInside)
        
        addANewTravelPlan.buttonAdd.addTarget(self, action: #selector(onAddButtonTapped), for: .touchUpInside)
    }

    @objc func onAddButtonTapped() {
        guard let currentUser = currentUser else {
            showAlert(message: "User not logged in")
            return
        }
        
        let creatorId = currentUser.uid
        let creatorName = currentUser.displayName!
        
        
        guard let travelTitle = addANewTravelPlan.textFieldTravelTitle.text,
              let travelStartDate = addANewTravelPlan.textFieldTravelStartDate.text,
              let travelEndDate = addANewTravelPlan.textFieldTravelEndDate.text,
              let travelCountryAndCity = addANewTravelPlan.textFieldCountryAndCity.text,
              !travelTitle.isEmpty, !travelStartDate.isEmpty, !travelEndDate.isEmpty, !travelCountryAndCity.isEmpty else {
            showAlert(message: "Please fill in all fields")
            return
        }
        
        guard let selectedCurrency = selectedCurrency else {
            showAlert(message: "Please select a currency.")
            return
        }

        // Create a new Travel instance using the updated model structure
        let travel = Travel(
            id: UUID().uuidString,
            creatorName: creatorName,
            creatorId: creatorId,
            travelTitle: travelTitle,
            travelStartDate: travelStartDate,
            travelEndDate: travelEndDate,
            countryAndCity: travelCountryAndCity,
            currency: selectedCurrency,
            categoryIds: [],
            expenseIds: [],
            participantIds: [creatorId]
        )
        
        saveTravelToFirestore(travel: travel)
    }
    

    func saveTravelToFirestore(travel: Travel) {
        let collectionTravelPlans = db.collection("travelPlans")
        
        do {
            try collectionTravelPlans.document(travel.id).setData(from: travel) { error in
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

extension AddANewTravelViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencies[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCurrency = currencies[row]
    }
}
