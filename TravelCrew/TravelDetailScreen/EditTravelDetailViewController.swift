//
//  EditTravelDetailViewController.swift
//  Packsync
//
//  Created by Xi Jia on 11/8/24.
//

import UIKit
import FirebaseFirestore

class EditTravelDetailViewController: UIViewController {
    var travel: Travel?
    weak var delegate: EditTravelDetailDelegate? // Renamed delegate
    
    let editTravelView = EditTravelDetailView()
    
    let currencies = ["USD", "EUR", "JPY", "GBP", "AUD", "CAD", "CHF", "CNY", "HKD", "INR"]
    
    override func loadView() {
        view = editTravelView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Edit Travel Plan"
        
        if let travel = travel {
            editTravelView.configure(with: travel)
        }
        
        editTravelView.currencyPicker.dataSource = self
        editTravelView.currencyPicker.delegate = self
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelEdit))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveEdit))
        
        editTravelView.startDatePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        editTravelView.endDatePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)

        editTravelView.buttonSave.addTarget(self, action: #selector(saveEdit), for: .touchUpInside)
        editTravelView.buttonDelete.addTarget(self, action: #selector(onDeleteTapped), for: .touchUpInside)
    }
    
    @objc func cancelEdit() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func saveEdit() {
        guard let updatedTitle = editTravelView.textFieldTravelTitle.text,
             let updatedStartDate = editTravelView.textFieldTravelStartDate.text,
             let updatedEndDate = editTravelView.textFieldTravelEndDate.text,
             let updatedCountryAndCity = editTravelView.textFieldCountryAndCity.text,
             let creatorId = travel?.creatorId else {
            print("Invalid input")
            return
            }
            
            // Validate country and city format
            let components = updatedCountryAndCity.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            guard components.count == 2, !components[0].isEmpty, !components[1].isEmpty else {
                showAlert(title: "Invalid Location", message: "Please enter the location in the format 'City, Country'")
                return
            }

            let startDate = editTravelView.startDatePicker.date
            let endDate = editTravelView.endDatePicker.date

            if endDate < startDate {
            showAlert(title: "Invalid Date", message: "End date cannot be earlier than start date.")
            return
            }
        
        let selectedCurrencyRow = editTravelView.currencyPicker.selectedRow(inComponent: 0)
        let selectedCurrency = currencies[selectedCurrencyRow]
        
        let updatedTravel = Travel(
            id: travel?.id ?? UUID().uuidString,
            creatorName: travel!.creatorName,
            creatorId: creatorId,
            travelTitle: updatedTitle,
            travelStartDate: formatDateForFirestore(updatedStartDate),
            travelEndDate: formatDateForFirestore(updatedEndDate),
            countryAndCity: updatedCountryAndCity,
            currency: selectedCurrency,
            categoryIds: travel?.categoryIds ?? [],
            expenseIds: travel?.expenseIds ?? [],
            participantIds: travel?.participantIds ?? []
        )
        
        let db = Firestore.firestore()
        db.collection("travelPlans").document(travel?.id ?? "").updateData([
            "travelTitle": updatedTitle,
            "travelStartDate": updatedTravel.travelStartDate,
            "travelEndDate": updatedTravel.travelEndDate,
            "countryAndCity": updatedCountryAndCity,
            "currency": selectedCurrency
        ]) { [weak self] error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
                self?.delegate?.didUpdateTravel(updatedTravel)
                
                // Send travelDataChanged notification
                NotificationCenter.default.post(
                    name: .travelDataChanged,
                    object: nil,
                    userInfo: ["travelId": updatedTravel.id]
                )
                
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        let startDate = editTravelView.startDatePicker.date
        let endDate = editTravelView.endDatePicker.date
        
        if endDate < startDate {
            showAlert(title: "Invalid Date", message: "End date cannot be earlier than start date.")
            sender.date = sender == editTravelView.startDatePicker ? endDate : startDate
        }
        
        if sender == editTravelView.startDatePicker {
            editTravelView.textFieldTravelStartDate.text = formatDate(startDate)
        } else {
            editTravelView.textFieldTravelEndDate.text = formatDate(endDate)
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    func formatDateForFirestore(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM dd, yyyy HH:mm"
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        
        return dateString
    }
    
    @objc func onDeleteTapped() {
        let alert = UIAlertController(title: "Delete Travel Plan", message: "Are you sure you want to delete this travel plan?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deleteTravel()
        }))
        
        present(alert, animated: true)
    }
    
    func deleteTravel() {
        guard let travel = travel else { return }
        
        let db = Firestore.firestore()
        db.collection("travelPlans").document(travel.id).delete { [weak self] error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
                self?.delegate?.didDeleteTravel(travel)
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
}

protocol EditTravelDetailDelegate: AnyObject {
    func didUpdateTravel(_ travel: Travel)
    func didDeleteTravel(_ travel: Travel)
}

extension EditTravelDetailViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // Single column
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencies[row] // Assuming `currencies` is a predefined array
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Handle selection if needed
        print("Selected currency: \(currencies[row])")
    }
}
