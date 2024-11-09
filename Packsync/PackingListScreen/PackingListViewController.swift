//
//  PackingListViewController.swift
//  Packsync
//
//  Created by Xi Jia on 11/8/24.
//

import UIKit
import FirebaseFirestore

class PackingListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PackingListViewControllerDelegate {
    
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
        db.collection("packingItem")
            .whereField("creatorEmail", isEqualTo: travel.creatorEmail)
            .whereField("travelTitle", isEqualTo: travel.travelTitle)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self?.packingItems = documents.compactMap { queryDocumentSnapshot in
                    try? queryDocumentSnapshot.data(as: PackingItem.self)
                }
                
                // Sort the packingItems array
                self?.packingItems.sort { (item1, item2) -> Bool in
                    let firstWord1 = item1.name.components(separatedBy: " ").first ?? ""
                    let firstWord2 = item2.name.components(separatedBy: " ").first ?? ""
                    return firstWord1.localizedCaseInsensitiveCompare(firstWord2) == .orderedAscending
                }
                
                DispatchQueue.main.async {
                    self?.packingListView.tableViewPackingList.reloadData()
                }
            }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return packingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PackingItemCell", for: indexPath)
        let item = packingItems[indexPath.row]
        cell.textLabel?.text = "\(item.name) (count: \(item.itemNumber ?? "1"))"
        cell.accessoryType = item.isPacked ? .checkmark : .none
        return cell
    }
    
    // MARK: - PackingListViewControllerDelegate
    
    func didAddPackingItem(_ item: PackingItem) {
//        packingItems.append(item)
        packingListView.tableViewPackingList.reloadData()
    }
}
