//
//  PackingItemDetailViewController.swift
//  Packsync
//
//  Created by Xi Jia on 11/19/24.
//


import UIKit
import FirebaseFirestore

class PackingItemDetailViewController: UIViewController {
    
    var packingItem: PackingItem!
    var travel: Travel!
    
    private let detailView = PackingItemDetailView()
    
    override func loadView() {
        view = detailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Packing Item Detail"
        setupEditButton()
        configureWithPackingItem()
        
        // Add observers for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(handlePackingItemUpdated(_:)), name: .packingItemUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePackingItemDeleted(_:)), name: .packingItemDeleted, object: nil)
    }
    
    deinit {
        // Remove observers when the view controller is deallocated
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupEditButton() {
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped))
        navigationItem.rightBarButtonItem = editButton
    }
    
    @objc private func editButtonTapped() {
        let editPackingItemVC = EditPackingItemViewController()
        editPackingItemVC.packingItem = packingItem
        editPackingItemVC.delegate = self
        let navController = UINavigationController(rootViewController: editPackingItemVC)
        present(navController, animated: true, completion: nil)
    }
    
    private func configureWithPackingItem() {
        detailView.nameLabel.text = packingItem.name
        detailView.itemNumberLabel.text = "Quantity: \(packingItem.itemNumber)"
        
        if packingItem.isPacked {
            detailView.packedByLabel.text = "Packed by: \(packingItem.isPackedBy ?? "Unknown User")"
            detailView.packedByLabel.isHidden = false
        } else {
            detailView.packedByLabel.isHidden = true
        }
    }
    
    @objc private func handlePackingItemUpdated(_ notification: Notification) {
        if let updatedItem = notification.object as? PackingItem, updatedItem.id == packingItem.id {
            self.packingItem = updatedItem
            configureWithPackingItem()
        }
    }
    
    @objc private func handlePackingItemDeleted(_ notification: Notification) {
        if let deletedItemId = notification.object as? String, deletedItemId == packingItem.id {
            navigationController?.popViewController(animated: true)
        }
    }
}

extension PackingItemDetailViewController: EditPackingItemViewControllerDelegate {
    func didUpdatePackingItem(_ item: PackingItem) {
        self.packingItem = item
        configureWithPackingItem()
    }
    
    func didDeletePackingItem(_ item: PackingItem) {
        navigationController?.popViewController(animated: true)
    }
}

// Add these notification names to your project, possibly in a separate file:
extension Notification.Name {
    static let packingItemUpdated = Notification.Name("packingItemUpdated")
    static let packingItemDeleted = Notification.Name("packingItemDeleted")
}
