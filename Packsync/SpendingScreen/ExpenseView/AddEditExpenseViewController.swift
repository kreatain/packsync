import UIKit

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
    private let saveButton = UIButton(type: .system)
    
    private let categoryLabel = UILabel()

    private var categories: [Category]
    private var participants: [User]
    private var travelId: String
    private var expense: SpendingItem?
    private var selectedReceiptURL: String?
    private var selectedPayerId: String?
    private var currencySymbol: String

    init(categories: [Category], participants: [User], travelId: String, currencySymbol: String, expense: SpendingItem? = nil) {
        self.categories = categories
        self.participants = participants
        self.travelId = travelId
        self.expense = expense
        self.currencySymbol = currencySymbol
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

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
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

        categoryLabel.text = "Select Category"
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
        receiptButton.addTarget(self, action: #selector(uploadReceipt), for: .touchUpInside)
        receiptButton.translatesAutoresizingMaskIntoConstraints = false

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

            saveButton.topAnchor.constraint(equalTo: receiptButton.bottomAnchor, constant: 20),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 44)
        ])
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
        selectedReceiptURL = expense.receiptURL
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

    @objc private func uploadReceipt() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
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

        let selectedCategoryIndex = categoryPicker.selectedRow(inComponent: 0)
        let selectedCategory = categories[selectedCategoryIndex]
        let date = ISO8601DateFormatter().string(from: datePicker.date)

        let newExpense = SpendingItem(
            amount: amount,
            description: description,
            date: date,
            addedByUserId: "currentUserId", // Replace with the current user ID
            spentByUserId: payerId,
            receiptURL: selectedReceiptURL
        )

        SpendingFirebaseManager.shared.addSpendingItem(to: selectedCategory.id, spendingItem: newExpense) { success in
            if success {
                self.dismiss(animated: true)
            } else {
                self.showAlert(title: "Error", message: "Failed to save expense.")
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            // Upload logic here (e.g., Firebase Storage)
            selectedReceiptURL = "uploaded/image/url" // Replace with actual URL after upload
        }
        picker.dismiss(animated: true)
    }
}

extension AddEditExpenseViewController {
    // MARK: - UIPickerViewDataSource Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // The picker has only one component
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count // The number of categories
    }

    // MARK: - UIPickerViewDelegate Methods
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let category = categories[row]
        return "\(category.emoji) \(category.name)" // Combine emoji and category name
    }
}
