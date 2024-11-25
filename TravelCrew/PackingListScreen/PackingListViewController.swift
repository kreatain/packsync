//
//  PackinListViewController.swift
//  Packsync
//
//  Created by Xi Jia on 11/17/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class PackingListViewController: UIViewController, EditPackingItemViewControllerDelegate {
    var packingListView: PackingListView?
    let noActiveplanLabel = UILabel()
    var travel: Travel?
    var currentUser: User?
    var packingItems: [PackingItem] = []
    var listener: ListenerRegistration?
    var travelID: String?
    
    // Initializer to accept travelID parameter
    init(travelID: String? = nil) {
        self.travelID = travelID
        super.init(nibName: nil, bundle: nil)
        print("[PackingViewController] Initialized with travelID: \(String(describing: travelID))")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(activeTravelPlanChanged), name: .activeTravelPlanChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userDidLogout), name: .userDidLogout, object: nil)
        updateUI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        listener?.remove()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCurrentUser() // Refresh user data when the view appears
    }
    
    @objc func activeTravelPlanChanged() {
        updateUI()
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Initialize and configure noActiveplanLabel
        noActiveplanLabel.text = "Please select an active travel plan to view Packing list details."
        noActiveplanLabel.textColor = .gray
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
        
        // Initialize packingListView
        packingListView = PackingListView(frame: view.bounds)
        packingListView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if let packingListView = packingListView {
            view.addSubview(packingListView)
        }
        
        // Initially hide the login prompt and no active plan label
        packingListView?.labelLoginPrompt.isHidden = true
        noActiveplanLabel.isHidden = true
    }
    
    func updateUI() {
        if Auth.auth().currentUser == nil {
            // User is not logged in
            userDidLogout()
        } else {
            // User is logged in
            packingListView?.labelLoginPrompt.isHidden = true
            packingListView?.tableViewPackingList.isHidden = false
            packingListView?.buttonAddPackingItem.isHidden = false
            packingListView?.labelTravelTitle.isHidden = false
            
            if let id = travelID {
                fetchTravelPlanDetails(for: id) { [weak self] travelPlan in
                    guard let self = self, let travelPlan = travelPlan else { return }
                    self.showPackingListView(for: travelPlan)
                    self.fetchPackingItems(for: id)
                }
            } else if let activePlan = TravelPlanManager.shared.activeTravelPlan {
                self.travel = activePlan
                showPackingListView(for: activePlan)
                fetchPackingItems(for: activePlan.id)
            } else {
                // No active plan; show login prompt instead of no active plan label.
                packingListView?.labelLoginPrompt.isHidden = false
                showNoActivePlanLabel()
            }
        }
    }
    
    @objc func userDidLogout() {
        DispatchQueue.main.async {
            self.packingItems.removeAll()

            self.packingListView?.tableViewPackingList.isHidden = true
            self.packingListView?.buttonAddPackingItem.isHidden = true
            self.packingListView?.labelTravelTitle.isHidden = true
            self.noActiveplanLabel.isHidden = true
            self.packingListView?.labelLoginPrompt.isHidden = false
            self.listener?.remove()
            self.packingListView?.tableViewPackingList.reloadData()
        }
    }

    func showNoActivePlanLabel() {
        packingListView?.isHidden = true
        noActiveplanLabel.isHidden = false
        packingItems.removeAll()
        listener?.remove()
        // Check if the user is logged out, show login prompt instead
        if Auth.auth().currentUser == nil {
            packingListView?.labelLoginPrompt.isHidden = false
            noActiveplanLabel.isHidden = true
        }
    }
 
    func fetchCurrentUser() {
        let db = Firestore.firestore()
        if let userId = Auth.auth().currentUser?.uid {
            // User is logged in
            packingListView?.labelLoginPrompt.isHidden = true
            db.collection("users").document(userId).getDocument { [weak self] (document, error) in
                if let document = document, document.exists {
                    self?.currentUser = try? document.data(as: User.self)
                    self?.updateUI()
                } else {
                    print("Document does not exist or error occurred: \(String(describing: error))")
                }
            }
        } else {
            // User is not logged in
            packingListView?.labelLoginPrompt.isHidden = false
            packingItems.removeAll()
            updateUI() 
        }
    }
    
    func fetchTravelPlanDetails(for id: String, completion: @escaping (Travel?) -> Void) {
        let db = Firestore.firestore()
        db.collection("travelPlans").document(id).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let travelPlan = Travel(
                    id: id,
                    creatorName: data?["creatorName"] as? String ?? "",
                    creatorId: data?["creatorId"] as? String ?? "",
                    travelTitle: data?["travelTitle"] as? String ?? "",
                    travelStartDate: data?["travelStartDate"] as? String ?? "",
                    travelEndDate: data?["travelEndDate"] as? String ?? "",
                    countryAndCity: data?["countryAndCity"] as? String ?? ""
                )
                completion(travelPlan)
            } else {
                print("Travel plan document does not exist")
                completion(nil)
            }
        }
    }
    
    func showPackingListView(for travelPlan: Travel) {
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
    
    @objc func addPackingItemTapped() {
        guard let travel = self.travel else {
            print("Error: No travel plan available")
            return
        }
        let addPackingItemVC = AddPackingItemViewController()
        addPackingItemVC.travel = travel
        addPackingItemVC.delegate = self
        let navController = UINavigationController(rootViewController: addPackingItemVC)
        present(navController, animated: true, completion: nil)
    }
    
    func fetchPackingItems(for travelId: String) {
        let db = Firestore.firestore()
        listener?.remove()
        listener = db.collection("travelPlans").document(travelId).collection("packingItems")
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
                    let creatorId = data["creatorId"] as? String ?? ""
                    let name = data["name"] as? String ?? ""
                    let itemNumber = data["itemNumber"] as? String ?? ""
                    let isPacked = data["isPacked"] as? Bool ?? false
                    let isPackedBy = data["isPackedBy"] as? String
                    let photoURL = data["photoURL"] as? String
                    return PackingItem(id: id, creatorId: creatorId, travelId: travelId, name: name, isPacked: isPacked, isPackedBy: isPackedBy, itemNumber: itemNumber, photoURL: photoURL)
                }
                self.packingItems.sort {
                    let firstLetter1 = $0.name.prefix(1).uppercased()
                    let firstLetter2 = $1.name.prefix(1).uppercased()
                    if $0.isPacked == $1.isPacked {
                        return firstLetter1 < firstLetter2
                    } else {
                        return !$0.isPacked
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

        guard let travel = self.travel else {
            print("Error: Travel object is nil")
            return
        }

        let db = Firestore.firestore()
        let id = packingItems[index].id
        let currentUser = Auth.auth().currentUser

        if let userId = currentUser?.uid {
            db.collection("users").document(userId).getDocument { [weak self] (document, error) in
                if let document = document, document.exists {
                    let profilePicURL = document.data()?["profileImageUrl"] as? String
                    let displayName = document.data()?["displayName"] as? String ?? "Unknown User"
                    let packedByValue = profilePicURL?.isEmpty == false ? profilePicURL! : displayName

                    let updateData: [String: Any] = [
                        "isPacked": self?.packingItems[index].isPacked ?? false,
                        "isPackedBy": (self?.packingItems[index].isPacked ?? false) ? packedByValue : NSNull()
                    ]

                    db.collection("travelPlans").document(travel.id).collection("packingItems").document(id).updateData(updateData) { error in
                        if let error = error {
                            print("Error updating document: \(error)")
                            DispatchQueue.main.async {
                                self?.packingItems[index].isPacked.toggle()
                                sender.isSelected = self?.packingItems[index].isPacked ?? false
                            }
                        } else {
                            print("Document successfully updated")
                            self?.packingItems[index].isPackedBy = self?.packingItems[index].isPacked == true ? packedByValue : nil
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
    }}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension PackingListViewController: UITableViewDelegate, UITableViewDataSource {
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
extension PackingListViewController: PackingListViewControllerDelegate {
    func didAddPackingItem(_ item: PackingItem) {
        DispatchQueue.main.async {
            self.packingListView?.tableViewPackingList.reloadData()
        }
    }
}
