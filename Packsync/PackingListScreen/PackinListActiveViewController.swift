//
//  PackinListActiveViewController.swift
//  Packsync
//
//  Created by Xi Jia on 11/17/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class PackinListActiveViewController: UIViewController, EditPackingItemViewControllerDelegate {
    
    private var packingListView: PackingListView?
    private let noActiveplanLabel = UILabel()
    var travel: Travel?
    private var packingItems: [PackingItem] = []
    private var listener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(activeTravelPlanChanged), name: .activeTravelPlanChanged, object: nil)
        updateUI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        listener?.remove()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        noActiveplanLabel.text = "Please select an active travel plan to view Packing list details."
        noActiveplanLabel.textAlignment = .center
        noActiveplanLabel.numberOfLines = 0
        noActiveplanLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noActiveplanLabel)
        
        NSLayoutConstraint.activate([
            noActiveplanLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noActiveplanLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noActiveplanLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            noActiveplanLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func activeTravelPlanChanged() {
        updateUI()
    }
    
    private func updateUI() {
        if let activePlan = TravelPlanManager.shared.activeTravelPlan {
            showPackingListView(for: activePlan)
            fetchPackingItems(for: activePlan.id)
        } else {
            showNoActivePlanLabel()
        }
    }
    
    private func showPackingListView(for travelPlan: Travel) {
        noActiveplanLabel.isHidden = true
        
        if packingListView == nil {
            packingListView = PackingListView(frame: view.bounds)
            packingListView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            if let packingListView = packingListView {
                view.addSubview(packingListView)
            }
        }
        
        packingListView?.isHidden = false
        packingListView?.configure(with: travelPlan)
        
        packingListView?.tableViewPackingList.delegate = self
        packingListView?.tableViewPackingList.dataSource = self
        
        packingListView?.buttonAddPackingItem.addTarget(self, action: #selector(addPackingItemTapped), for: .touchUpInside)
    }
    
    private func showNoActivePlanLabel() {
        packingListView?.isHidden = true
        noActiveplanLabel.isHidden = false
        packingItems.removeAll()
        listener?.remove() // Remove the listener when there's no active plan
    }
    
    @objc private func addPackingItemTapped() {
        guard let activePlan = TravelPlanManager.shared.activeTravelPlan else {
            print("Error: No active travel plan")
            return
        }
        
        let addPackingItemVC = AddPackingItemViewController()
        addPackingItemVC.travel = activePlan
        addPackingItemVC.delegate = self
        let navController = UINavigationController(rootViewController: addPackingItemVC)
        present(navController, animated: true, completion: nil)
    }

    private func fetchPackingItems(for travelId: String) {
        guard let travel = TravelPlanManager.shared.activeTravelPlan else { return }
        let db = Firestore.firestore()
        listener?.remove() // Remove any existing listener
        
        listener = db.collection("travelPlans").document(travel.id).collection("packingItems")
            .whereField("creatorId", isEqualTo: travel.creatorId)
            .whereField("travelId", isEqualTo: travel.id)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching documents: \(error.localizedDescription)")
                    return
                }
                guard let documents = querySnapshot?.documents else {
                    print("No documents found")
                    return
                }
                
                self.packingItems = documents.compactMap { queryDocumentSnapshot in
                    let data = queryDocumentSnapshot.data()
                    let id = queryDocumentSnapshot.documentID
                    let name = data["name"] as? String ?? ""
                    let itemNumber = data["itemNumber"] as? String ?? ""
                    let isPacked = data["isPacked"] as? Bool ?? false
                    let isPackedBy = data["isPackedBy"] as? String
                    
                    return PackingItem(id: id, creatorId: travel.creatorId, travelId: travel.id, name: name, isPacked: isPacked, isPackedBy: isPackedBy, itemNumber: itemNumber)
                }
                
                // Sort packing items by first letter of first word and move packed items to the bottom
                self.packingItems.sort {
                    let firstLetter1 = $0.name.prefix(1).uppercased()
                    let firstLetter2 = $1.name.prefix(1).uppercased()
                    
                    if $0.isPacked == $1.isPacked {
                        return firstLetter1 < firstLetter2
                    } else {
                        return !$0.isPacked // Move packed items to the bottom
                    }
                }
                
                DispatchQueue.main.async {
                    self.packingListView?.tableViewPackingList.reloadData()
                }
            }
    }
    
    @objc func checkboxTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index < packingItems.count else {
            print("Error: Invalid index")
            return
        }
        
        packingItems[index].isPacked.toggle()
        sender.isSelected = packingItems[index].isPacked
        
        guard let travel = TravelPlanManager.shared.activeTravelPlan else {
            print("Error: Travel object is nil")
            return
        }
        
        let db = Firestore.firestore()
        let id = packingItems[index].id
        let currentUser = Auth.auth().currentUser
        
        // Fetch the user's profile data
        if let userId = currentUser?.uid {
            db.collection("users").document(userId).getDocument { [weak self] (document, error) in
                if let document = document, document.exists {
                    let profilePicURL = document.data()?["profileImageUrl"] as? String
                    let displayName = document.data()?["displayName"] as? String ?? "Unknown User"
                    
                    let packedByValue: String
                    if let profilePicURL = profilePicURL, !profilePicURL.isEmpty {
                        packedByValue = profilePicURL

                    } else {
                        packedByValue = "\(displayName)"
                       
                    }
                    
                    let updateData: [String: Any] = [
                        "isPacked": self?.packingItems[index].isPacked ?? false,
                        "isPackedBy": (self?.packingItems[index].isPacked ?? false) ? packedByValue : NSNull()
                    ]
                    
                    db.collection("travelPlans").document(travel.id).collection("packingItems").document(id).updateData(updateData) { error in
                        if let error = error {
                            print("Error updating document: \(error)")
                            // Revert the change if the update fails
                            DispatchQueue.main.async {
                                self?.packingItems[index].isPacked.toggle()
                                sender.isSelected = self?.packingItems[index].isPacked ?? false
                            }
                        } else {
                            print("Document successfully updated")
                            // Update the local packingItems array
                            self?.packingItems[index].isPackedBy = self?.packingItems[index].isPacked == true ? packedByValue : nil
                            // Refresh the UI
                            DispatchQueue.main.async {
                                self?.packingListView?.tableViewPackingList.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                            }
                        }
                    }
                } else {
                    print("User document does not exist")
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension PackinListActiveViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return packingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PackingItemCell", for: indexPath) as? PackingItemCell else {
            return UITableViewCell()
        }
        
        let packingItem = packingItems[indexPath.row]
        cell.configure(with: packingItem)
        cell.checkboxButton.tag = indexPath.row
        cell.checkboxButton.addTarget(self, action: #selector(checkboxTapped(_:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
                    
        let item = packingItems[indexPath.row]
        let detailVC = PackingItemDetailViewController()
        detailVC.packingItem = item
        detailVC.travel = self.travel
        navigationController?.pushViewController(detailVC, animated: true)
                
    }
    
    // MARK: - EditPackingItemViewControllerDelegate
        func didUpdatePackingItem(_ item: PackingItem) {
            if let index = packingItems.firstIndex(where: { $0.id == item.id }) {
                packingItems[index] = item
                DispatchQueue.main.async {
                    self.packingListView?.tableViewPackingList.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }
            }
        }

        func didDeletePackingItem(_ item: PackingItem) {
            if let index = packingItems.firstIndex(where: { $0.id == item.id }) {
                packingItems.remove(at: index)
                DispatchQueue.main.async {
                    self.packingListView?.tableViewPackingList.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                }
            }
        }
}

// MARK: - PackingListViewControllerDelegate
extension PackinListActiveViewController: PackingListViewControllerDelegate {
    func didAddPackingItem(_ item: PackingItem) {
        DispatchQueue.main.async {
            self.packingListView?.tableViewPackingList.reloadData()
        }
    }
}








