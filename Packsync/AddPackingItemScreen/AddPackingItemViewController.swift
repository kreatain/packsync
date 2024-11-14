//
//  AddPackingItemViewController.swift
//  Packsync
//
//  Created by Xi Jia on 11/13/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class AddPackingItemViewController: UIViewController {
    
    let addPackingItemView = AddPackingItemView()
    var travel: Travel?
    weak var delegate: PackingListViewControllerDelegate?
    
    override func loadView() {
        view = addPackingItemView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add Packing Item"
        
        addPackingItemView.buttonAdd.addTarget(self, action: #selector(addItemButtonTapped), for: .touchUpInside)
    }
    
    @objc func addItemButtonTapped() {
        guard let itemName = addPackingItemView.textFieldItemName.text, !itemName.isEmpty,
              let itemNumber = addPackingItemView.textFieldItemCount.text, !itemNumber.isEmpty,
              let travel = travel else {
            showAlert(message: "Please enter both item name and count.")
            return
        }
        
        // Create new PackingItem using travel's creatorId and travelId
        let newItem = PackingItem(
            id: UUID().uuidString,
            creatorId: travel.creatorId,
            travelId: travel.id,
            name: itemName,
            isPacked: false,
            isPackedBy: nil,  // Initially, the item is not packed by anyone
            itemNumber: itemNumber
        )
        
        savePackingItemToFirestore(newItem)
    }
    
    func savePackingItemToFirestore(_ item: PackingItem) {
        guard let travel = travel else {
            showAlert(message: "Travel information is missing.")
            return
        }
        
        let db = Firestore.firestore()
        
        do {
            try db.collection("trips").document(travel.id).collection("packingItems").addDocument(from: item) { error in
                if let error = error {
                    print("Error adding document: \(error)")
                    self.showAlert(message: "Failed to add item. Please try again.")
                } else {
                    print("Document added successfully")
                    self.delegate?.didAddPackingItem(item)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        } catch let error {
            print("Error writing item to Firestore: \(error)")
            self.showAlert(message: "Failed to add item. Please try again.")
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

protocol PackingListViewControllerDelegate: AnyObject {
    func didAddPackingItem(_ item: PackingItem)
}
