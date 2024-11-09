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
    weak var delegate: EditTravelViewControllerDelegate?
    
    let editTravelView = EditTravelDetailView()
    
    override func loadView() {
        view = editTravelView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Edit Travel Plan"
        
        if let travel = travel {
            editTravelView.configure(with: travel)
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelEdit))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveEdit))
        
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
              let creatorEmail = travel?.creatorEmail else {
            print("Invalid input")
            return
        }
        
        let updatedTravel = Travel(creatorEmail: creatorEmail,
                                   travelTitle: updatedTitle,
                                   travelStartDate: formatDateForFirestore(updatedStartDate),
                                   travelEndDate: formatDateForFirestore(updatedEndDate),
                                   countryAndCity: updatedCountryAndCity)
        
        // Update Firestore
        let db = Firestore.firestore()
        db.collection("travelPlans").whereField("creatorEmail", isEqualTo: creatorEmail)
            .whereField("travelTitle", isEqualTo: travel?.travelTitle ?? "")
            .getDocuments { [weak self] (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    for document in querySnapshot!.documents {
                        document.reference.updateData([
                            "travelTitle": updatedTitle,
                            "travelStartDate": updatedTravel.travelStartDate,
                            "travelEndDate": updatedTravel.travelEndDate,
                            "countryAndCity": updatedCountryAndCity
                        ]) { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                print("Document successfully updated")
                                self?.delegate?.didUpdateTravel(updatedTravel)
                                self?.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
    }
    
    func formatDateForFirestore(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM dd, yyyy HH:mm"
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        
        return dateString // Return original string if parsing fails
    }
    
    @objc func onDeleteTapped() {
        // Show a confirmation alert
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
        db.collection("travelPlans")
            .whereField("creatorEmail", isEqualTo: travel.creatorEmail)
            .whereField("travelTitle", isEqualTo: travel.travelTitle)
            .getDocuments { [weak self] (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                    return
                }
                
                guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                    print("No matching documents")
                    return
                }
                
                // Assuming there's only one matching document
                let document = documents[0]
                document.reference.delete { error in
                    if let error = error {
                        print("Error removing document: \(error)")
                    } else {
                        print("Document successfully removed!")
                        // Notify the delegate that the travel plan was deleted
                        self?.delegate?.didDeleteTravel(travel)
                        // Dismiss the edit view controller
                        self?.dismiss(animated: true, completion: nil)
                    }
                }
            }
    }
}

//protocol EditTravelDetailViewControllerDelegate: AnyObject {
//    func didUpdateTravel(_ travel: Travel)
//    func didDeleteTravel(_ travel: Travel)
//}
//
//extension TravelDetailViewController: EditTravelDetailViewControllerDelegate {
//    func didUpdateTravel(_ travel: Travel) {
//        self.travel = travel
//        updateUI()
//    }
//    
//    func didDeleteTravel(_ travel: Travel) {
//        navigationController?.popViewController(animated: true)
//    }
//}
