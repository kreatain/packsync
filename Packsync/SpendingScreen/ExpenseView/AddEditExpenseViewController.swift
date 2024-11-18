import UIKit

class AddEditExpenseViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private let categoryPicker = UIPickerView()
    private let amountTextField = UITextField()
    private let descriptionTextField = UITextField()
    private let datePicker = UIDatePicker()
    private let payerPicker = UIPickerView()
    private let receiptButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)

    private let dateLabel = UILabel()
    private let categoryLabel = UILabel()
    private let payerLabel = UILabel()

    private var categories: [Category]
    private var participants: [User]
    private var travelId: String
    private var expense: SpendingItem?
    private var selectedReceiptURL: String?

    init(categories: [Category], participants: [User], travelId: String, expense: SpendingItem? = nil) {
        self.categories = categories
        self.participants = participants
        self.travelId = travelId
        self.expense = expense
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

        amountTextField.placeholder = "Expense Amount (\(Locale.current.currencySymbol ?? "$"))"
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

        payerPicker.translatesAutoresizingMaskIntoConstraints = false
        payerPicker.dataSource = self
        payerPicker.delegate = self

        receiptButton.setTitle("Upload Receipt", for: .normal)
        receiptButton.addTarget(self, action: #selector(uploadReceipt), for: .touchUpInside)
        receiptButton.translatesAutoresizingMaskIntoConstraints = false

        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 8
        saveButton.addTarget(self, action: #selector(saveExpense), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(amountTextField)
        view.addSubview(descriptionTextField)
        view.addSubview(dateLabel)
        view.addSubview(datePicker)
        view.addSubview(categoryLabel)
        view.addSubview(categoryPicker)
        view.addSubview(payerLabel)
        view.addSubview(payerPicker)
        view.addSubview(receiptButton)
        view.addSubview(saveButton)

        NSLayoutConstraint.activate([
            amountTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            amountTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            amountTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            descriptionTextField.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 20),
            descriptionTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            dateLabel.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor, constant: 20),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            datePicker.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            categoryLabel.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 20),
            categoryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            categoryPicker.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 10),
            categoryPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoryPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            payerLabel.topAnchor.constraint(equalTo: categoryPicker.bottomAnchor, constant: 20),
            payerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            payerPicker.topAnchor.constraint(equalTo: payerLabel.bottomAnchor, constant: 10),
            payerPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            payerPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            receiptButton.topAnchor.constraint(equalTo: payerPicker.bottomAnchor, constant: 20),
            receiptButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            saveButton.topAnchor.constraint(equalTo: receiptButton.bottomAnchor, constant: 20),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
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
        if let payerIndex = participants.firstIndex(where: { $0.id == expense.spentByUserId }) {
            payerPicker.selectRow(payerIndex, inComponent: 0, animated: false)
        }
        selectedReceiptURL = expense.receiptURL
    }

    @objc private func uploadReceipt() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary // Change to .camera for camera input
        present(imagePicker, animated: true)
    }

    @objc private func saveExpense() {
        guard let amountText = amountTextField.text,
              let amount = Double(amountText),
              let description = descriptionTextField.text,
              !description.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields.")
            return
        }

        let selectedCategoryIndex = categoryPicker.selectedRow(inComponent: 0)
        let selectedCategory = categories[selectedCategoryIndex]
        let selectedPayerIndex = payerPicker.selectedRow(inComponent: 0)
        let spentByUserId = participants[selectedPayerIndex].id
        let date = ISO8601DateFormatter().string(from: datePicker.date)

        let newExpense = SpendingItem(
            amount: amount,
            description: description,
            date: date,
            addedByUserId: "currentUserId", // Replace with current user ID
            spentByUserId: spentByUserId,
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
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            // Handle image upload logic here
            print("Receipt image selected: \(image)")
        }
        picker.dismiss(animated: true)
    }
}

extension AddEditExpenseViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView == categoryPicker ? categories.count : participants.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == categoryPicker {
            return "\(categories[row].emoji) \(categories[row].name)"
        } else {
            return participants[row].displayName ?? participants[row].email
        }
    }
}
