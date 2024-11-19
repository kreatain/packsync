import UIKit
import FirebaseAuth
import FirebaseStorage

class AddEditExpenseViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
    private let saveButton = UIButton(type: .system)
    
    private let categoryLabel = UILabel()

    private var categories: [Category]
    private var participants: [User]
    private var travelId: String
    private var expense: SpendingItem?
    private var selectedReceiptURL: String?
    private var selectedPayerId: String?
    private var currencySymbol: String
    private var fixedCategory: Category?
    private var categoryPickerHeightConstraint: NSLayoutConstraint?

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
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if selectedReceiptURL != nil, expense == nil {
            deleteReceiptFromStorage()
        }
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        categoryPickerHeightConstraint = categoryPicker.heightAnchor.constraint(equalToConstant: 150)

        NSLayoutConstraint.activate([
            categoryPickerHeightConstraint!,
            
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
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

        receiptButton.setTitle("Upload Receipt", for: .normal)
        receiptButton.addTarget(self, action: #selector(showPhotoOptions), for: .touchUpInside)
        receiptButton.translatesAutoresizingMaskIntoConstraints = false

        receiptImageView.contentMode = .scaleAspectFit
        receiptImageView.layer.borderWidth = 1
        receiptImageView.layer.borderColor = UIColor.lightGray.cgColor
        receiptImageView.translatesAutoresizingMaskIntoConstraints = false
        receiptImageView.isHidden = true // Initially hidden
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewReceiptFullscreen))
                receiptImageView.addGestureRecognizer(tapGesture)
                receiptImageView.isUserInteractionEnabled = true

        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 8
        saveButton.addTarget(self, action: #selector(saveExpense), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false

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
        contentView.addSubview(saveButton)

        NSLayoutConstraint.activate([
            amountTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            amountTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            amountTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            descriptionTextField.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 20),
            descriptionTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            dateLabel.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor, constant: 20),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            datePicker.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            categoryLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            categoryPicker.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 10),
            categoryPicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            categoryPicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            payerLabel.topAnchor.constraint(equalTo: categoryPicker.bottomAnchor, constant: 20),
            payerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            payerButton.centerYAnchor.constraint(equalTo: payerLabel.centerYAnchor),
            payerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            receiptButton.topAnchor.constraint(equalTo: payerLabel.bottomAnchor, constant: 20),
            receiptButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            receiptImageView.topAnchor.constraint(equalTo: receiptButton.bottomAnchor, constant: 20),
            receiptImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            receiptImageView.widthAnchor.constraint(equalToConstant: 150),
            receiptImageView.heightAnchor.constraint(equalToConstant: 150),

            saveButton.topAnchor.constraint(equalTo: receiptImageView.bottomAnchor, constant: 20),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        if fixedCategory != nil {
            categoryLabel.text = "Category: \(fixedCategory?.emoji ?? "") \(fixedCategory?.name ?? "")"
            categoryPicker.isHidden = true
            categoryPickerHeightConstraint?.constant = 0
        } else {
            categoryLabel.text = "Select Category"
            categoryPicker.isHidden = false
            categoryPickerHeightConstraint?.constant = 150
        }
    }

    private func configureWithExpense() {
        guard let expense = expense else { return }
        amountTextField.text = "\(expense.amount)"
        descriptionTextField.text = expense.description
        datePicker.date = ISO8601DateFormatter().date(from: expense.date) ?? Date()
        
        if let categoryIndex = categories.firstIndex(where: { $0.spendingItemIds.contains(expense.id) }) {
            categoryPicker.selectRow(categoryIndex, inComponent: 0, animated: false)
        }
        if let participant = participants.first(where: { $0.id == expense.spentByUserId }) {
            payerButton.setTitle(participant.displayName ?? participant.email, for: .normal)
            selectedPayerId = participant.id
        }
        if let receiptURL = expense.receiptURL, let url = URL(string: receiptURL) {
            loadImageFromURL(url)
        }
    }

    private func loadImageFromURL(_ url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.receiptImageView.image = image
                    self.receiptImageView.isHidden = false // Make visible after loading
                }
            }
        }
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
        let alert = UIAlertController(title: "Select Payer", message: nil, preferredStyle: .actionSheet)
        participants.forEach { user in
            let action = UIAlertAction(title: user.displayName ?? user.email, style: .default) { _ in
                self.payerButton.setTitle(user.displayName ?? user.email, for: .normal)
                self.selectedPayerId = user.id
            }
            alert.addAction(action)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            receiptImageView.image = selectedImage
            receiptImageView.isHidden = false // Show thumbnail only after adding a photo
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
                receiptURL: selectedReceiptURL ?? existingExpense.receiptURL // Use the updated receipt URL if available
            )

            SpendingFirebaseManager.shared.updateSpendingItem(spendingItem: updatedExpense) { success in
                if success {
                    NotificationCenter.default.post(name: .travelDataChanged, object: nil)
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
                receiptURL: selectedReceiptURL
            )

            SpendingFirebaseManager.shared.addSpendingItem(to: selectedCategory.id, spendingItem: newExpense) { success in
                if success {
                    NotificationCenter.default.post(name: .travelDataChanged, object: nil)
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

}
