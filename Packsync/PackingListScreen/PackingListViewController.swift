//
//  PackingListViewController.swift
//  Packsync
//
//  Created by 许多 on 10/24/24.
//
import UIKit
class PackingListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var travel: Travel?
    var packingItems: [PackingItem] = []
    let packingListView = PackingListView()
    
    override func loadView() {
        view = packingListView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Packing List"
        
        if let travel = travel {
            packingListView.configure(with: travel)
            fetchPackingItems(for: travel)
        }
        
//        packingListView.tableViewPackingList.delegate = self
//        packingListView.tableViewPackingList.dataSource = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPackingItem))
    }
    
    func fetchPackingItems(for travel: Travel) {
        // Implement Firestore fetch logic here
        // Update packingItems array and reload table view
    }
    
    @objc func addPackingItem() {
        // Implement the logic to add a new packing item
        // You might want to show an alert with a text field to enter the item name
    }
    
    // UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return packingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PackingItemCell", for: indexPath)
        let item = packingItems[indexPath.row]
        cell.textLabel?.text = item.name
        cell.accessoryType = item.isPacked ? .checkmark : .none
        return cell
    }
    
    // UITableViewDelegate methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Toggle the packed status of the item
        packingItems[indexPath.row].isPacked.toggle()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        // Update the item in Firestore
    }
}
