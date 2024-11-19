//
//
//  PackingListViewController.swift
//  Packsync
//
//  Created by Xi Jia on 11/8/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class PackingListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PackingListViewControllerDelegate, EditPackingItemViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let packingListView = PackingListView()
    var travel: Travel?
    var packingItems: [PackingItem] = []
    var selectedItemIndex: Int?
    
    override func loadView() {
        view = packingListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Packing List"
        
        packingListView.tableViewPackingList.delegate = self
        packingListView.tableViewPackingList.dataSource = self
        
        packingListView.buttonAddPackingItem.addTarget(self, action: #selector(addPackingItemButtonTapped), for: .touchUpInside)
        
        fetchPackingItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPackingItems()
    }
    
    @objc func addPackingItemButtonTapped() {
        let addPackingItemVC = AddPackingItemViewController()
        addPackingItemVC.travel = self.travel
        addPackingItemVC.delegate = self
        let navController = UINavigationController(rootViewController: addPackingItemVC)
        present(navController, animated: true, completion: nil)
    }

    func fetchPackingItems() {
        guard let travel = travel else { return }

        let db = Firestore.firestore()
        db.collection("travelPlans").document(travel.id).collection("packingItems")
            .whereField("creatorId", isEqualTo: travel.creatorId)
            .whereField("travelId", isEqualTo: travel.id)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
               
                self?.packingItems = documents.compactMap { queryDocumentSnapshot in
                    let data = queryDocumentSnapshot.data()
                    let id = queryDocumentSnapshot.documentID
                    let name = data["name"] as? String ?? ""
                    let itemNumber = data["itemNumber"] as? String ?? ""
                    let isPacked = data["isPacked"] as? Bool ?? false
                    let isPackedBy = data["isPackedBy"] as? String
                    let photoURL = data["photoURL"] as? String

                    return PackingItem(id: id, creatorId: travel.creatorId, travelId: travel.id, name: name, isPacked: isPacked, isPackedBy: isPackedBy, itemNumber: itemNumber, photoURL: photoURL)
                }
                
                DispatchQueue.main.async {
                    self?.packingListView.tableViewPackingList.reloadData()
                }
            }
    }

    @objc func checkboxTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index < packingItems.count else {
            print("Error: Invalid index")
            return
        }
        
        // Toggle packed state
        packingItems[index].isPacked.toggle()
        sender.isSelected = packingItems[index].isPacked
        
        guard let travel = travel else {
            print("Error: Travel object is nil")
            return
        }
        
        let db = Firestore.firestore()
        let id = packingItems[index].id
        guard let currentUser = Auth.auth().currentUser else {
            print("Error: No current user")
            return
        }
        
        db.collection("users").document(currentUser.uid).getDocument { [weak self] (document, error) in
            if let document = document, document.exists {
                let displayName = document.data()?["displayName"] as? String ?? "Unknown User"
                let updateData: [String: Any] = [
                    "isPacked": self?.packingItems[index].isPacked ?? false,
                    "isPackedBy": (self?.packingItems[index].isPacked ?? false) ? displayName : NSNull()
                ]
                
                db.collection("travelPlans").document(travel.id).collection("packingItems").document(id).updateData(updateData) { error in
                    if let error = error {
                        print("Error updating document: \(error)")
                        DispatchQueue.main.async {
                            self?.packingItems[index].isPacked.toggle() // Revert change on error
                            sender.isSelected = self?.packingItems[index].isPacked ?? false
                        }
                    } else {
                        print("Document successfully updated")
                        self?.packingItems[index].isPackedBy = self?.packingItems[index].isPacked == true ? displayName : nil
                        
                        // Move packed item to bottom of list
                        if self?.packingItems[index].isPacked == true {
                            let packedItem = self?.packingItems.remove(at: index)
                            if let item = packedItem {
                                self?.packingItems.append(item)
                            }
                        }
                        
                        // Sort items by name while ensuring packed items are at the bottom
                        self?.packingItems.sort {
                            if $0.isPacked == $1.isPacked {
                                return $0.name < $1.name // Sort alphabetically if both are packed or unpacked
                            }
                            return !$0.isPacked // Unpacked items come first
                        }

                        DispatchQueue.main.async {
                            self?.packingListView.tableViewPackingList.reloadData()
                        }
                    }
                }
            } else {
                print("User document does not exist")
            }
        }
    }
    
    @objc func cameraButtonTapped(_ sender: UIButton) {
        selectedItemIndex = sender.tag
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage,
              let selectedItemIndex = selectedItemIndex else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        uploadImage(image, forItemAt: selectedItemIndex)
        
        dismiss(animated: true, completion: nil)
    }
    
    func uploadImage(_ image: UIImage, forItemAt index: Int) {
        guard index < packingItems.count,
              let imageData = image.jpegData(compressionQuality: 0.5),
              let travel = travel else { return }
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child("packing_item_photos/\(travel.id)/\(packingItems[index].id).jpg")
        
        let uploadTask = imageRef.putData(imageData, metadata: nil) { [weak self] (metadata, error) in
            guard error == nil else {
                print("Error uploading image: \(error!.localizedDescription)")
                return
            }
            
            imageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print("Error getting download URL: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self?.updatePackingItemPhotoURL(at: index, with: downloadURL.absoluteString)
            }
        }
    }
    
    func updatePackingItemPhotoURL(at index: Int, with url: String) {
        guard index < packingItems.count, let travel = travel else { return }
        
        let item = packingItems[index]
        let db = Firestore.firestore()
        
        db.collection("travelPlans").document(travel.id).collection("packingItems").document(item.id).updateData(["photoURL": url]) { [weak self] error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated with new photo URL")
                self?.packingItems[index].photoURL = url
                DispatchQueue.main.async {
                    self?.packingListView.tableViewPackingList.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return packingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PackingItemCell", for: indexPath) as? PackingItemCell else {
            fatalError("Unable to dequeue PackingItemCell")
        }
        
        let item = packingItems[indexPath.row]
        cell.configure(with: item)
        cell.checkboxButton.tag = indexPath.row
        cell.checkboxButton.addTarget(self, action: #selector(checkboxTapped(_:)), for: .touchUpInside)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = packingItems[indexPath.row]
        let detailVC = PackingItemDetailViewController()
        detailVC.packingItem = item
        detailVC.travel = self.travel
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // MARK: - Delegate Methods
    
    func didAddPackingItem(_ item: PackingItem) {
        packingListView.tableViewPackingList.reloadData()
    }

    func didUpdatePackingItem(_ item: PackingItem) {
        if let index = packingItems.firstIndex(where: { $0.id == item.id }) {
            packingItems[index] = item
            packingListView.tableViewPackingList.reloadData()
        }
    }

    func didDeletePackingItem(_ item: PackingItem) {
        if let index = packingItems.firstIndex(where: { $0.id == item.id }) {
            packingItems.remove(at: index)
            packingListView.tableViewPackingList.reloadData()
        }
    }
}
