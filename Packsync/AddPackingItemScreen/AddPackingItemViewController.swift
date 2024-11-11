import UIKit
import FirebaseFirestore

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
    
//    @objc func addItemButtonTapped() {
//        guard let itemName = addPackingItemView.textFieldItemName.text, !itemName.isEmpty,
//              let itemNumber = addPackingItemView.textFieldItemCount.text, !itemNumber.isEmpty,
//              let travel = travel else {
//            showAlert(message: "Please enter both item name and count.")
//            return
//        }
//        
//        let newItem = PackingItem(
//            creatorEmail: travel.creatorEmail,
//            travelTitle: travel.travelTitle,
//            name: itemName,
//            itemNumber: itemNumber
//        )
//        
//        savePackingItemToFirestore(newItem)
//    }
//
    @objc func addItemButtonTapped() {
        guard let itemName = addPackingItemView.textFieldItemName.text, !itemName.isEmpty,
              let itemNumber = addPackingItemView.textFieldItemCount.text, !itemNumber.isEmpty,
              let travel = travel else {
            showAlert(message: "Please enter both item name and count.")
            return
        }
        
        let newItem = PackingItem(
            id: UUID().uuidString,
            creatorEmail: travel.creatorEmail,
            travelTitle: travel.travelTitle,
            name: itemName,
            isPacked: addPackingItemView.switchIsPacked.isOn,
            itemNumber: itemNumber
        )
        
        savePackingItemToFirestore(newItem)
    }
    func savePackingItemToFirestore(_ item: PackingItem) {
        let db = Firestore.firestore()
        
        do {
            try db.collection("packingItem").addDocument(from: item) { error in
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
