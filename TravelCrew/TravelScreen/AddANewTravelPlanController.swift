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
    
    let currencies = [
        "USD ($)", "EUR (€)", "GBP (£)", "JPY (¥)", "CNY (¥)", "INR (₹)",
        "AUD ($)", "CAD ($)", "CHF (₣)", "NZD ($)", "HKD ($)", "SGD ($)",
        "KRW (₩)", "ZAR (R)", "MXN ($)", "BRL (R$)", "RUB (₽)", "SEK (kr)",
        "NOK (kr)", "DKK (kr)", "PLN (zł)", "THB (฿)", "IDR (Rp)", "TRY (₺)",
        "ILS (₪)", "MYR (RM)", "SAR (﷼)", "AED (د.إ)", "EGP (£)", "VND (₫)",
        "PHP (₱)", "PKR (₨)", "LKR (₨)", "BDT (৳)", "CZK (Kč)", "HUF (Ft)",
        "RON (lei)", "UAH (₴)", "KZT (₸)", "NGN (₦)", "KES (KSh)", "TZS (TSh)",
        "GHS (GH₵)", "MAD (د.م.)", "DZD (دج)", "TND (د.ت)", "IQD (ع.د)", "OMR (ر.ع.)",
        "BHD (ب.د)", "QAR (ر.ق)", "KWD (د.ك)", "JOD (د.ا)", "LBP (ل.ل)", "BND ($)",
        "MOP (MOP$)", "TWD (NT$)", "THB (฿)", "KHR (៛)", "LAK (₭)", "MMK (K)",
        "AFN (؋)", "IRR (﷼)", "MDL (L)", "ISK (kr)", "BAM (KM)", "HRK (kn)"
    ]
    var selectedCurrency: String?
    
    override func loadView() {
        view = addANewTravelPlan
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add a new travel plan"
        
        currentUser = Auth.auth().currentUser
        
        addANewTravelPlan.currencyPicker.dataSource = self
        addANewTravelPlan.currencyPicker.delegate = self
        addANewTravelPlan.buttonAdd.addTarget(self, action: #selector(onAddButtonTapped), for: .touchUpInside)
        
        addANewTravelPlan.textFieldTravelStartDate.addTarget(self, action: #selector(dateChanged), for: .editingDidEnd)
        addANewTravelPlan.textFieldTravelEndDate.addTarget(self, action: #selector(dateChanged), for: .editingDidEnd)
    }

    @objc func dateChanged(_ sender: UITextField) {
        guard let startDateString = addANewTravelPlan.textFieldTravelStartDate.text,
              let endDateString = addANewTravelPlan.textFieldTravelEndDate.text,
              !startDateString.isEmpty,
              !endDateString.isEmpty else {
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
        guard let startDate = dateFormatter.date(from: startDateString),
              let endDate = dateFormatter.date(from: endDateString) else {
            return
        }
        
        if endDate < startDate {
            showAlert(title: "Invalid Date", message: "End date cannot be earlier than start date.")
            sender.text = ""
        }
    }

    @objc func onAddButtonTapped() {
        guard let currentUser = currentUser else {
            showAlert(title: "Error", message: "User not logged in")
            return
        }
        
        let creatorId = currentUser.uid
        let creatorName = currentUser.displayName ?? "Unknown User"
        
        guard let travelTitle = addANewTravelPlan.textFieldTravelTitle.text,
              let travelStartDate = addANewTravelPlan.textFieldTravelStartDate.text,
              let travelEndDate = addANewTravelPlan.textFieldTravelEndDate.text,
              let travelCountryAndCity = addANewTravelPlan.textFieldCountryAndCity.text,
              !travelTitle.isEmpty, !travelStartDate.isEmpty, !travelEndDate.isEmpty, !travelCountryAndCity.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields")
            return
        }
        
        guard let selectedCurrency = selectedCurrency else {
            showAlert(title: "Error", message: "Please select a currency.")
            return
        }
        
        let components = travelCountryAndCity.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        guard components.count == 2, !components[0].isEmpty, !components[1].isEmpty else {
            showAlert(title: "Error", message: "Please enter the location in the format 'City, Country'")
            return
        }

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
            participantIds: [creatorId],
            participantNames: [creatorName],
            balanceIds: [],
            billboardIds: []
        )
        
        saveTravelToFirestore(travel: travel)
    }
    
    func saveTravelToFirestore(travel: Travel) {
        let collectionTravelPlans = db.collection("travelPlans")
        
        do {
            try collectionTravelPlans.document(travel.id).setData(from: travel) { error in
                if let error = error {
                    print("Error adding document: \(error.localizedDescription)")
                    self.showAlert(title: "Error", message: "Failed to save travel plan. Please try again.")
                } else {
                    print("Document added successfully")
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } catch {
            print("Error encoding travel data: \(error.localizedDescription)")
            self.showAlert(title: "Error", message: "Failed to save travel plan. Please try again.")
        }
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
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
