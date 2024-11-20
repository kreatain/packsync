import UIKit

class BudgetAddEditViewController: UIViewController {
    private let textFieldName = UITextField()
    private let textFieldBudget = UITextField()
    private let emojiTextField = EmojiTextField()
    private let saveButton = UIButton(type: .system)
    
    private var category: Category?
    private var travelId: String
    private var totalBudget: Double
    private var currencySymbol: String // Default currency symbol
    
    init(category: Category? = nil, travelId: String, totalBudget: Double,  currencySymbol: String = "$") {
        self.category = category
        self.travelId = travelId
        self.totalBudget = totalBudget
        self.currencySymbol = currencySymbol
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWithCategory()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        textFieldName.placeholder = "Category Name"
        textFieldName.borderStyle = .roundedRect
        textFieldName.translatesAutoresizingMaskIntoConstraints = false
        
        textFieldBudget.placeholder = "\(currencySymbol) Budget Amount"
        textFieldBudget.keyboardType = .decimalPad
        textFieldBudget.borderStyle = .roundedRect
        textFieldBudget.translatesAutoresizingMaskIntoConstraints = false
        
        emojiTextField.placeholder = "Choose Emoji"
        emojiTextField.borderStyle = .roundedRect
        emojiTextField.translatesAutoresizingMaskIntoConstraints = false
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        saveButton.layer.cornerRadius = 8
        saveButton.addTarget(self, action: #selector(saveCategory), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(textFieldName)
        view.addSubview(textFieldBudget)
        view.addSubview(emojiTextField)
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            textFieldName.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textFieldName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textFieldName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            textFieldBudget.topAnchor.constraint(equalTo: textFieldName.bottomAnchor, constant: 20),
            textFieldBudget.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textFieldBudget.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            emojiTextField.topAnchor.constraint(equalTo: textFieldBudget.bottomAnchor, constant: 20),
            emojiTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emojiTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func configureWithCategory() {
        guard let category = category else { return }
        textFieldName.text = category.name
        emojiTextField.text = category.emoji
        textFieldBudget.text = "\(category.budgetAmount)"
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func dismissViewController() {
        dismiss(animated: true)
    }
    
    @objc private func saveCategory() {
        guard let name = textFieldName.text,
              let budgetText = textFieldBudget.text,
              let budget = Double(budgetText),
              let emoji = emojiTextField.text,
              !name.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields.")
            return
        }
        
        if emoji.count != 1 || !emoji.containsOnlyEmoji {
            showAlert(title: "Invalid Emoji", message: "Please enter only one valid emoji.")
            emojiTextField.text = ""
            return
        }
        
        if budget <= 0 {
            showAlert(title: "Invalid Budget", message: "Budget must be a positive number.")
            textFieldBudget.text = ""
            return
        }
        
        if var category = category {
            category.name = name
            category.budgetAmount = budget
            category.emoji = emoji
            SpendingFirebaseManager.shared.updateCategory(in: travelId, category: category) { success in
                self.handleCompletion(success: success)
            }
        } else {
            let newCategory = Category(name: name, budgetAmount: budget, emoji: emoji)
            SpendingFirebaseManager.shared.addCategory(to: travelId, category: newCategory) { success in
                self.handleCompletion(success: success)
            }
        }
    }
    
    private func handleCompletion(success: Bool) {
        if success {
            print("Category added/updated successfully. Refreshing travel plan...")
            NotificationCenter.default.post(name: .travelDataChanged, object: nil)
            DispatchQueue.main.async {
                self.dismiss(animated: true) // Dismiss the modal instead of popping the navigation controller
            }
        } else {
            self.showAlert(title: "Error", message: "Failed to save the category. Please try again.")
        }
    }
    
}

extension String {
    var containsOnlyEmoji: Bool {
        return !isEmpty && self.allSatisfy { $0.isEmoji }
    }
}

extension Character {
    var isEmoji: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        return scalar.properties.isEmoji && (scalar.value > 0x238C || unicodeScalars.count > 1)
    }
}
