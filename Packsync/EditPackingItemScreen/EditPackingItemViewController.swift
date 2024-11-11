//
//  EditPackingItemViewController.swift
//  Packsync
//
//  Created by Xi Jia on 11/8/24.
//

import UIKit
import FirebaseFirestore

protocol EditPackingItemViewControllerDelegate: AnyObject {
    func didUpdatePackingItem(_ item: PackingItem)
    func didDeletePackingItem(_ item: PackingItem)
}

class EditPackingItemViewController: UIViewController {
    
    let editPackingItemView = EditPackingItemView()
    var packingItem: PackingItem?
    weak var delegate: EditPackingItemViewControllerDelegate?
    
    override func loadView() {
        view = editPackingItemView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Edit Packing Item"
        
        editPackingItemView.buttonSave.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        editPackingItemView.buttonDelete.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        
        if let item = packingItem {
            editPackingItemView.textFieldItemName.text = item.name
            editPackingItemView.textFieldItemCount.text = item.itemNumber
        }
    }
    
    @objc func saveButtonTapped() {
        guard let name = editPackingItemView.textFieldItemName.text, !name.isEmpty,
              let count = editPackingItemView.textFieldItemCount.text, !count.isEmpty,
              var updatedItem = packingItem else {
            return
        }
        
        updatedItem.name = name
        updatedItem.itemNumber = count
        
        let db = Firestore.firestore()
        db.collection("packingItem").document(updatedItem.id).setData([
            "name": updatedItem.name,
            "itemNumber": updatedItem.itemNumber
        ], merge: true) { [weak self] error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
                self?.delegate?.didUpdatePackingItem(updatedItem)
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func deleteButtonTapped() {
        guard let item = packingItem else { return }
        
        let db = Firestore.firestore()
        db.collection("packingItem").document(item.id).delete() { [weak self] error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed")
                self?.delegate?.didDeletePackingItem(item)
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
}
