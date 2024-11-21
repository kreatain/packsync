//
//  PackingItemDetailViewController.swift
//  Packsync
//
//  Created by Xi Jia on 11/19/24.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class PackingItemDetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        
        detailView.uploadPhotoButton.addTarget(self, action: #selector(uploadPhotoButtonTapped), for: .touchUpInside)
        
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

        loadImage()
    }

    private func loadImage() {
        print("photoURL:\(packingItem.photoURL ?? "nil")") // Debugging output
        
        if let photoURL = packingItem.photoURL, let url = URL(string: photoURL) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                if let error = error {
                    print("Error loading image: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self?.detailView.itemImageView.image = UIImage(systemName: "photo")
                    }
                    return
                }
                
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.detailView.itemImageView.image = image
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.detailView.itemImageView.image = UIImage(systemName: "photo")
                    }
                }
            }.resume()
        } else {
            detailView.itemImageView.image = UIImage(systemName: "photo")
        }
    }
    
    @objc private func uploadPhotoButtonTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        uploadImage(image)
        dismiss(animated: true, completion: nil)
    }
    
    private func uploadImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child("packing_item_photos/\(travel.id)/\(packingItem.id).jpg")
        
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
                
                self?.updatePackingItemPhotoURL(with: downloadURL.absoluteString)
            }
        }
    }
    
    private func updatePackingItemPhotoURL(with url: String) {
        packingItem.photoURL = url
        
        // Update Firestore with new photo URL
        updatePackingItemInFirestore()
        
        // Load the new image into the view immediately after updating the URL.
        loadImage()
    }

    private func updatePackingItemInFirestore() {
        let db = Firestore.firestore()
        
        // Prepare data to update in Firestore.
        db.collection("travelPlans").document(travel.id).collection("packingItems").document(packingItem.id).updateData([
            "photoURL": packingItem.photoURL ?? NSNull(),
            "name": packingItem.name,
            "itemNumber": packingItem.itemNumber,
            "isPacked": packingItem.isPacked,
            "isPackedBy": packingItem.isPackedBy ?? NSNull()
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
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
