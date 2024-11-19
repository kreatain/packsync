//
//  PackingItemDetailViewController.swift
//  Packsync
//
//  Created by Xi Jia on 11/19/24.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

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
            
            // Set packedByLabel text based on packing status.
            if packingItem.isPacked {
                detailView.packedByLabel.text = "Packed by: \(packingItem.isPackedBy ?? "Unknown User")"
                detailView.packedByLabel.isHidden = false  // Show label if packed
            } else {
                detailView.packedByLabel.isHidden = true   // Hide label if not packed
            }

            if let photoURL = packingItem.photoURL, let url = URL(string: photoURL) {
                URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self?.detailView.itemImageView.image = image
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
        updatePackingItemInFirestore()
        
        DispatchQueue.main.async { [weak self] in
            if let url = URL(string: url) {
                URLSession.shared.dataTask(with: url) { data, _, error in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self?.detailView.itemImageView.image = image
                        }
                    }
                }.resume()
            }
        }
    }

    private func updatePackingItemInFirestore(completion: ((Error?) -> Void)? = nil) {
        let db = Firestore.firestore()
        let dataToUpdate: [String: Any] = [
            "photoURL": packingItem.photoURL ?? NSNull()
        ]
        
        // Only update photoURL without affecting isPacked or isPackedBy
        db.collection("travelPlans").document(travel.id).collection("packingItems").document(packingItem.id).updateData(dataToUpdate) { [weak self] error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
                self?.configureWithPackingItem()
            }
            completion?(error)
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

