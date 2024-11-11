//
//  PackingListViewController.swift
//  Packsync
//
//  Created by Xi Jia on 11/8/24.
//

import UIKit
import FirebaseFirestore

class PackingListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PackingListViewControllerDelegate,EditPackingItemViewControllerDelegate {
    
    let packingListView = PackingListView()
    var travel: Travel?
    var packingItems: [PackingItem] = []
    
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
    
//    func fetchPackingItems() {
//        guard let travel = travel else { return }
//        
//        let db = Firestore.firestore()
//        db.collection("packingItem")
//            .whereField("creatorEmail", isEqualTo: travel.creatorEmail)
//            .whereField("travelTitle", isEqualTo: travel.travelTitle)
//            .addSnapshotListener { [weak self] querySnapshot, error in
//                guard let documents = querySnapshot?.documents else {
//                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
//                    return
//                }
//                
//                self?.packingItems = documents.compactMap { queryDocumentSnapshot in
//                    try? queryDocumentSnapshot.data(as: PackingItem.self)
//                }
//                
//                // Sort the packingItems array
//                self?.packingItems.sort { (item1, item2) -> Bool in
//                    let firstWord1 = item1.name.components(separatedBy: " ").first ?? ""
//                    let firstWord2 = item2.name.components(separatedBy: " ").first ?? ""
//                    return firstWord1.localizedCaseInsensitiveCompare(firstWord2) == .orderedAscending
//                }
//                
//                DispatchQueue.main.async {
//                    self?.packingListView.tableViewPackingList.reloadData()
//                }
//            }
//    }
    func fetchPackingItems() {
        guard let travel = travel else { return }
        
        let db = Firestore.firestore()
        db.collection("packingItem")
            .whereField("creatorEmail", isEqualTo: travel.creatorEmail)
            .whereField("travelTitle", isEqualTo: travel.travelTitle)
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
                    
                    return PackingItem(id: id, creatorEmail: travel.creatorEmail, travelTitle: travel.travelTitle, name: name, isPacked: isPacked, itemNumber: itemNumber)
                }
                
                // Sort the packingItems array if needed
                
                DispatchQueue.main.async {
                    self?.packingListView.tableViewPackingList.reloadData()
                }
            }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return packingItems.count
    }
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "PackingItemCell", for: indexPath)
//        let item = packingItems[indexPath.row]
//        cell.textLabel?.text = "\(item.name) (count: \(item.itemNumber ?? "1"))"
//        cell.accessoryType = item.isPacked ? .checkmark : .none
//        return cell
//    }
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "PackingItemCell", for: indexPath)
//            let item = packingItems[indexPath.row]
//            cell.textLabel?.text = "\(item.name) (count: \(item.itemNumber ?? "1"))"
//            cell.accessoryType = item.isPacked ? .checkmark : .none
//            
//            // Add a switch for isPacked
//            let switchView = UISwitch(frame: .zero)
//            switchView.setOn(item.isPacked, animated: true)
//            switchView.tag = indexPath.row
//            switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
//            cell.accessoryView = switchView
//            
//            return cell
//        }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PackingItemCell", for: indexPath)
        let item = packingItems[indexPath.row]
        cell.textLabel?.text = "\(item.name) (count: \(item.itemNumber ?? "1"))"
        
        // Add a switch for isPacked
        let switchView = UISwitch(frame: .zero)
        switchView.setOn(item.isPacked, animated: false)
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = switchView
        
        return cell
    }
    
//    @objc func switchChanged(_ sender: UISwitch) {
//        let index = sender.tag
//        packingItems[index].isPacked = sender.isOn
//        
//        // Update the item in Firestore
//        let db = Firestore.firestore()
//        let id = packingItems[index].id
//        db.collection("packingItem").document(id).updateData(["isPacked": sender.isOn]) { error in
//            if let error = error {
//                print("Error updating document: \(error)")
//            } else {
//                print("Document successfully updated")
//            }
//        }
//    }
    @objc func switchChanged(_ sender: UISwitch) {
        let index = sender.tag
        packingItems[index].isPacked = sender.isOn
        
        // Update the item in Firestore
        let db = Firestore.firestore()
        let id = packingItems[index].id
        db.collection("packingItem").document(id).updateData(["isPacked": sender.isOn]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = packingItems[indexPath.row]
        let editPackingItemVC = EditPackingItemViewController()
        editPackingItemVC.packingItem = item
        editPackingItemVC.delegate = self
        let navController = UINavigationController(rootViewController: editPackingItemVC)
        present(navController, animated: true, completion: nil)
    }
    
    // MARK: - PackingListViewControllerDelegate

    func didAddPackingItem(_ item: PackingItem) {
        // packingItems.append(item)
        packingListView.tableViewPackingList.reloadData()
    }
    

    // MARK: - EditPackingItemViewControllerDelegate
    
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
