import UIKit
import FirebaseAuth
import FirebaseStorage

protocol ParticipantSelectorDelegate: AnyObject {
    func didUpdateSelectedParticipants(_ selectedParticipants: Set<String>)
}

class AddEditExpenseViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate   {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let categoryPicker = UIPickerView()
    private let amountTextField = UITextField()
    private let descriptionTextField = UITextField()
    private let dateLabel = UILabel()
    private let datePicker = UIDatePicker()
    private let payerLabel = UILabel()
    private let payerButton = UIButton(type: .system)
    private let receiptButton = UIButton(type: .system)
    private let receiptImageView = UIImageView()
    
    private let participantsLabel = UILabel()
    private let participantsButton = UIButton(type: .system)
    
    private let saveButton = UIButton(type: .system)
    
    private let categoryLabel = UILabel()
    
    private var categories: [Category]
    private var participants: [User]
    private var travelId: String
    private var expense: SpendingItem?
    private var selectedReceiptURL: String?
    private var selectedPayerId: String?
    private var selectedParticipants = Set<String>()
    private var currencySymbol: String
    private var fixedCategory: Category?
    private var categoryPickerHeightConstraint: NSLayoutConstraint?
    private var receiptImageViewHeightConstraint: NSLayoutConstraint?
    
    init(categories: [Category], participants: [User], travelId: String, currencySymbol: String, expense: SpendingItem? = nil, fixedCategory: Category? = nil) {
        self.categories = categories
        self.participants = participants
        self.travelId = travelId
        self.expense = expense
        self.currencySymbol = currencySymbol
        self.fixedCategory = fixedCategory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWithExpense()
        
        // Initialize selectedParticipants with all participants
        if selectedParticipants.isEmpty {
            selectedParticipants = Set(participants.map { $0.id })
        }
        updateParticipantsButtonText()
        
        // Pre-select the current user as the payer
        if selectedPayerId == nil, let currentUserId = Auth.auth().currentUser?.uid {
            selectedPayerId = currentUserId
            let currentUser = participants.first { $0.id == currentUserId }
            payerButton.setTitle(currentUser?.displayName ?? currentUser?.email ?? "Select Payer", for: .normal)
        }
        
        // Show alert only if there are no categories and no fixed category
        if categories.isEmpty && fixedCategory == nil {
            showAlertAndGoBack()
            return // Stop further execution to prevent crashes due to empty categories
        }
        
    }
    
    @objc private func debugTap(_ recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: view)
        if let hitView = view.hitTest(location, with: nil) {
            print("Tapped view: \(hitView)")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if selectedReceiptURL != nil, expense == nil {
            deleteReceiptFromStorage()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update the scrollView's contentSize dynamically
        scrollView.contentSize = contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        view.addSubview(saveButton)
        scrollView.addSubview(contentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        categoryPickerHeightConstraint = categoryPicker.heightAnchor.constraint(equalToConstant: 100)
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 8
        saveButton.addTarget(self, action: #selector(saveExpense), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            saveButton.topAnchor.constraint(equalTo: contentView.bottomAnchor),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            saveButton.heightAnchor.constraint(equalToConstant: 44),
        ])
            
        amountTextField.placeholder = "Expense Amount (\(currencySymbol))"
        amountTextField.keyboardType = .decimalPad
        amountTextField.borderStyle = .roundedRect
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionTextField.placeholder = "Description"
        descriptionTextField.borderStyle = .roundedRect
        descriptionTextField.translatesAutoresizingMaskIntoConstraints = false
        
        dateLabel.text = "Expense Date"
        dateLabel.font = .boldSystemFont(ofSize: 16)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        datePicker.datePickerMode = .date
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        categoryLabel.font = .boldSystemFont(ofSize: 16)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        categoryPicker.translatesAutoresizingMaskIntoConstraints = false
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        
        payerLabel.text = "Paid By"
        payerLabel.font = .boldSystemFont(ofSize: 16)
        payerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        payerButton.setTitle("Select Payer", for: .normal)
        payerButton.setTitleColor(.systemBlue, for: .normal)
        payerButton.addTarget(self, action: #selector(showPayerPicker), for: .touchUpInside)
        payerButton.translatesAutoresizingMaskIntoConstraints = false
        
        participantsLabel.text = "Related To"
        participantsLabel.font = .boldSystemFont(ofSize: 16)
        participantsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        participantsButton.setTitle("All Members", for: .normal)
        participantsButton.setTitleColor(.systemBlue, for: .normal)
        participantsButton.addTarget(self, action: #selector(toggleParticipantSelector), for: .touchUpInside)
        participantsButton.translatesAutoresizingMaskIntoConstraints = false
        
        receiptButton.setTitle("Upload Receipt", for: .normal)
        receiptButton.addTarget(self, action: #selector(showPhotoOptions), for: .touchUpInside)
        receiptButton.translatesAutoresizingMaskIntoConstraints = false
        
        receiptImageView.translatesAutoresizingMaskIntoConstraints = false
        receiptImageView.contentMode = .scaleAspectFit
        receiptImageView.layer.borderWidth = 1
        receiptImageView.layer.borderColor = UIColor.lightGray.cgColor
        
        receiptImageViewHeightConstraint = receiptImageView.heightAnchor.constraint(equalToConstant: 80)
        receiptImageViewHeightConstraint?.isActive = true
        receiptImageView.isHidden = false // Ensure it remains in the layout hierarchy
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewReceiptFullscreen))
        receiptImageView.addGestureRecognizer(tapGesture)
        receiptImageView.isUserInteractionEnabled = true
        
        contentView.addSubview(amountTextField)
        contentView.addSubview(descriptionTextField)
        contentView.addSubview(dateLabel)
        contentView.addSubview(datePicker)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(categoryPicker)
        contentView.addSubview(payerLabel)
        contentView.addSubview(payerButton)
        contentView.addSubview(receiptButton)
        contentView.addSubview(receiptImageView)
        contentView.addSubview(participantsLabel)
        contentView.addSubview(participantsButton)
        
        NSLayoutConstraint.activate([
            descriptionTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            descriptionTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            amountTextField.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor, constant: 20),
            amountTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            amountTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            dateLabel.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 15),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            datePicker.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            categoryLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            categoryPicker.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 10),
            categoryPicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            categoryPicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            categoryPickerHeightConstraint!,
            
            payerLabel.topAnchor.constraint(equalTo: categoryPicker.bottomAnchor, constant: 20),
            payerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            payerButton.centerYAnchor.constraint(equalTo: payerLabel.centerYAnchor),
            payerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            participantsLabel.topAnchor.constraint(equalTo: payerButton.bottomAnchor, constant: 20),
            participantsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            participantsButton.centerYAnchor.constraint(equalTo: participantsLabel.centerYAnchor),
            participantsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            receiptButton.topAnchor.constraint(equalTo: participantsLabel.bottomAnchor, constant: 20),
            receiptButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            receiptImageView.topAnchor.constraint(equalTo: receiptButton.bottomAnchor, constant: 20),
            receiptImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            receiptImageView.widthAnchor.constraint(equalToConstant: 100),
            receiptImageView.heightAnchor.constraint(equalToConstant: 80),
            
        ])
        
        adjustForFixedCategory()
    }
    
    private func adjustForFixedCategory() {
        if let fixedCategory = fixedCategory {
            categoryLabel.text = "Category: \(fixedCategory.emoji) \(fixedCategory.name)"
            categoryPicker.isHidden = true
            categoryPickerHeightConstraint?.constant = 0
        } else {
            categoryLabel.text = "Select Category"
            categoryPicker.isHidden = false
            categoryPickerHeightConstraint?.constant = 100
        }
        view.setNeedsLayout()
        view.layoutIfNeeded() // Update layout after changing constraints
    }
    
    private func showReceiptImage(_ image: UIImage) {
        receiptImageView.image = image
        receiptImageViewHeightConstraint?.constant = 80 // Set the desired height
        receiptImageView.isHidden = false // Ensure it's interactable
        view.layoutIfNeeded() // Refresh the layout
    }
    
    private func hideReceiptImage() {
        receiptImageView.image = nil
        receiptImageViewHeightConstraint?.constant = 0 // Collapse the height
        view.layoutIfNeeded() // Refresh the layout
    }
    
    private func configureWithExpense() {
        guard let expense = expense else { 
            // If there's no existing expense, clear the receipt image
            hideReceiptImage()
            return 
        }
        
        // Populate fields with existing expense data
        amountTextField.text = "\(expense.amount)"
        descriptionTextField.text = expense.description
        datePicker.date = ISO8601DateFormatter().date(from: expense.date) ?? Date()
        selectedParticipants = Set(expense.participants)
        
        if let categoryIndex = categories.firstIndex(where: { $0.spendingItemIds.contains(expense.id) }) {
            categoryPicker.selectRow(categoryIndex, inComponent: 0, animated: false)
        }
        
        if let participant = participants.first(where: { $0.id == expense.spentByUserId }) {
            payerButton.setTitle(participant.displayName ?? participant.email, for: .normal)
            selectedPayerId = participant.id
        }
        
        // Handle receipt image
        if let receiptURLString = expense.receiptURL, let receiptURL = URL(string: receiptURLString) {
            loadImageFromURL(receiptURL)
        } else {
            hideReceiptImage()
        }
        
        // Update the participants button text dynamically
        updateParticipantsButtonText()
    }
    
    private func updateParticipantsButtonText() {
        if selectedParticipants.count == participants.count {
            participantsButton.setTitle("All Members", for: .normal)
        } else if selectedParticipants.isEmpty {
            participantsButton.setTitle("Select Members", for: .normal)
        } else {
            participantsButton.setTitle("Partial Members", for: .normal)
        }
    }
    
    private func loadImageFromURL(_ url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.showReceiptImage(image) // Show image and adjust layout
                }
            }
        }
    }
    
    private func clearReceiptImage() {
        hideReceiptImage() // Adjust layout to hide the image
    }
    
    private func deleteReceiptFromStorage() {
        guard let selectedReceiptURL = selectedReceiptURL else { return }
        let storageRef = Storage.storage().reference(forURL: selectedReceiptURL)
        storageRef.delete { error in
            if let error = error {
                print("Error deleting receipt from storage: \(error)")
            } else {
                print("Receipt deleted successfully.")
            }
        }
    }
    
    @objc private func toggleParticipantSelector() {
        if selectedParticipants.isEmpty {
            // Default to select all members
            selectedParticipants = Set(participants.map { $0.id })
        }
        let participantSelectorVC = ParticipantSelectorViewController(participants: participants, selectedParticipants: selectedParticipants)
        participantSelectorVC.delegate = self
        navigationController?.pushViewController(participantSelectorVC, animated: true)
    }
    
    @objc private func showPhotoOptions() {
        let alertController = UIAlertController(title: "Select Photo", message: "Choose a photo from your library or take a new one.", preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePickerController = UIImagePickerController()
                imagePickerController.sourceType = .camera
                imagePickerController.delegate = self
                self.present(imagePickerController, animated: true)
            }
        })
        
        alertController.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.delegate = self
            self.present(imagePickerController, animated: true)
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alertController, animated: true)
    }
    
    @objc private func viewReceiptFullscreen() {
        guard let image = receiptImageView.image else { return }
        let fullscreenVC = FullscreenImageViewController(image: image)
        present(fullscreenVC, animated: true)
    }
    
    @objc private func showPayerPicker() {
        let alertController = UIAlertController(title: "Select Payer", message: nil, preferredStyle: .actionSheet)
        
        for participant in participants {
            let action = UIAlertAction(title: participant.displayName ?? participant.email, style: .default) { _ in
                self.payerButton.setTitle(participant.displayName ?? participant.email, for: .normal)
                self.selectedPayerId = participant.id
            }
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            showReceiptImage(selectedImage)
            uploadReceiptToStorage(selectedImage) { [weak self] url in
                guard let self = self else { return }
                self.selectedReceiptURL = url
            }
        }
        picker.dismiss(animated: true)
    }
    
    private func uploadReceiptToStorage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            completion(nil)
            return
        }
        let receiptId = UUID().uuidString
        let storageRef = Storage.storage().reference().child("receipts/\(receiptId).jpg")
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Failed to upload receipt: \(error.localizedDescription)")
                completion(nil)
                return
            }
            storageRef.downloadURL { url, _ in
                completion(url?.absoluteString)
            }
        }
    }
    
    @objc private func saveExpense() {
        guard let amountText = amountTextField.text,
              let amount = Double(amountText),
              let description = descriptionTextField.text,
              let payerId = selectedPayerId,
              !description.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields.")
            return
        }
        
        // Validate the selected participants
        if selectedParticipants.isEmpty {
            showAlert(title: "Error", message: "Please select at least one participant.")
            return
        }
        
        // Fetch the current user's ID
        guard let userId = Auth.auth().currentUser?.uid else {
            showAlert(title: "Error", message: "Failed to identify the current user.")
            return
        }
        
        let selectedCategory: Category
        
        if let fixedCategory = fixedCategory {
            // Use the fixed category if present
            selectedCategory = fixedCategory
        } else {
            // Otherwise, get the selected category from the picker
            let selectedCategoryIndex = categoryPicker.selectedRow(inComponent: 0)
            guard selectedCategoryIndex >= 0 && selectedCategoryIndex < categories.count else {
                showAlert(title: "Error", message: "Please select a valid category.")
                return
            }
            selectedCategory = categories[selectedCategoryIndex]
        }
        
        let date = ISO8601DateFormatter().string(from: datePicker.date)
        
        // Check if we are editing an existing expense
        if let existingExpense = expense {
            // Update existing expense
            let updatedExpense = SpendingItem(
                id: existingExpense.id,
                amount: amount,
                description: description,
                date: date,
                addedByUserId: existingExpense.addedByUserId, // Retain the original user ID
                spentByUserId: payerId,
                categoryId: selectedCategory.id,
                receiptURL: selectedReceiptURL ?? existingExpense.receiptURL, // Use the updated receipt URL if available
                participants: Array(selectedParticipants),
                travelId: travelId
            )
            
            SpendingFirebaseManager.shared.updateSpendingItem(spendingItem: updatedExpense) { success in
                if success {
                    NotificationCenter.default.post(
                        name: .travelDataChanged,
                        object: nil,
                        userInfo: ["expense": updatedExpense]
                    )
                    self.dismiss(animated: true)
                } else {
                    self.showAlert(title: "Error", message: "Failed to update expense.")
                }
            }
        } else {
            // Create a new expense
            let newExpense = SpendingItem(
                id: UUID().uuidString,
                amount: amount,
                description: description,
                date: date,
                addedByUserId: userId,
                spentByUserId: payerId,
                categoryId: selectedCategory.id,
                receiptURL: selectedReceiptURL,
                participants: Array(selectedParticipants),
                travelId: travelId
            )
            
            SpendingFirebaseManager.shared.addSpendingItem(to: selectedCategory.id, spendingItem: newExpense) { success in
                if success {
                    NotificationCenter.default.post(
                        name: .travelDataChanged,
                        object: nil,
                        userInfo: ["expense": newExpense]
                    )
                    NotificationCenter.default.post(name: .categoryDataChanged, object: nil, userInfo: ["categoryId": selectedCategory.id])
                    print("Notification sent for category ID: \(selectedCategory.id)")
                    self.dismiss(animated: true)
                } else {
                    self.showAlert(title: "Error", message: "Failed to save expense.")
                }
            }
        }
    }
    
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showAlertAndGoBack() {
        let alert = UIAlertController(
            title: "No Categories Found",
            message: "Please create a category first to proceed.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            // Dismiss the modal after the alert is acknowledged
            self.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
    
    // MARK: - UIPickerView DataSource & Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let category = categories[row]
        return "\(category.emoji) \(category.name)"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ParticipantSelectorCell", for: indexPath) as? ParticipantSelectorCell else {
            fatalError("Failed to dequeue ParticipantSelectorCell")
        }
        
        let participant = participants[indexPath.row]
        let isChecked = selectedParticipants.contains(participant.id)
        cell.configure(with: participant.displayName ?? participant.email, isChecked: isChecked)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let participant = participants[indexPath.row]
        if selectedParticipants.contains(participant.id) {
            selectedParticipants.remove(participant.id)
        } else {
            selectedParticipants.insert(participant.id)
        }
        
        // Reload the cell for the updated checkbox state
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        // Update the button text dynamically
        updateParticipantsButtonText()
    }
    
}

extension AddEditExpenseViewController: ParticipantSelectorDelegate {
    func didUpdateSelectedParticipants(_ selectedParticipants: Set<String>) {
        self.selectedParticipants = selectedParticipants
        updateParticipantsButtonText()
    }
}
