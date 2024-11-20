//
//  ExpenseDetailsViewController.swift
//  Packsync
//
//  Created by Xu Yang on 11/15/24.
//

import UIKit

class ExpenseDetailsViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let editButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)
    
    private let descriptionLabel = UILabel()
    private let categoryLabel = UILabel()
    private let amountLabel = UILabel()
    private let spentByLabel = UILabel()
    private let dateLabel = UILabel()
    private let receiptImageView = UIImageView()
    
    var expense: SpendingItem
    private var category: Category
    private var spender: User?
    private var currencySymbol: String
    private var travelId: String 
    private var categories: [Category]
    private var participants: [User]
    
    var onDeinit: ((ExpenseDetailsViewController) -> Void)?

    init(expense: SpendingItem, 
         category: Category, 
         spender: User?, 
         currencySymbol: String, 
         travelId: String, 
         categories: [Category], 
         participants: [User]) {
        self.expense = expense
        self.category = category
        self.spender = spender
        self.currencySymbol = currencySymbol
        self.travelId = travelId
        self.categories = categories
        self.participants = participants
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWithExpense()
        
        NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(handleTravelDataChanged),
                    name: .travelDataChanged,
                    object: nil
                )
    }
    
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure Buttons
        editButton.setTitle("Edit", for: .normal)
        editButton.setTitleColor(.white, for: .normal)
        editButton.backgroundColor = .systemBlue
        editButton.layer.cornerRadius = 8
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.addTarget(self, action: #selector(editExpense), for: .touchUpInside)
        
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.backgroundColor = .systemRed
        deleteButton.layer.cornerRadius = 8
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.addTarget(self, action: #selector(confirmDeleteExpense), for: .touchUpInside)
        
        view.addSubview(editButton)
        view.addSubview(deleteButton)
        
        // Configure Labels
        descriptionLabel.font = .boldSystemFont(ofSize: 18)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        categoryLabel.font = .systemFont(ofSize: 16)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        amountLabel.font = .systemFont(ofSize: 16)
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        spentByLabel.font = .systemFont(ofSize: 16)
        spentByLabel.translatesAutoresizingMaskIntoConstraints = false
        
        dateLabel.font = .systemFont(ofSize: 16)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        receiptImageView.contentMode = .scaleAspectFit
        receiptImageView.translatesAutoresizingMaskIntoConstraints = false
        receiptImageView.isUserInteractionEnabled = true
        receiptImageView.isHidden = true // Initially hidden
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewReceiptFullscreen))
        receiptImageView.addGestureRecognizer(tapGesture)
        
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(amountLabel)
        contentView.addSubview(spentByLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(receiptImageView)
        
        // Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            categoryLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            amountLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 20),
            amountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            spentByLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 20),
            spentByLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            dateLabel.topAnchor.constraint(equalTo: spentByLabel.bottomAnchor, constant: 20),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            receiptImageView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            receiptImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            receiptImageView.widthAnchor.constraint(equalToConstant: 200),
            receiptImageView.heightAnchor.constraint(equalToConstant: 200),
            receiptImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            editButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            editButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            editButton.bottomAnchor.constraint(equalTo: deleteButton.topAnchor, constant: -10),
            editButton.heightAnchor.constraint(equalToConstant: 44),
            
            deleteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            deleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            deleteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            deleteButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func configureWithExpense() {
        descriptionLabel.text = "Description: \(expense.description)"
        categoryLabel.text = "Category: \(category.name)"
        amountLabel.text = "Amount: \(currencySymbol)\(String(format: "%.2f", expense.amount))"
        spentByLabel.text = "Spent By: \(spender?.displayName ?? spender?.email ?? "Unknown")"
        dateLabel.text = "Date: \(formattedDate(from: expense.date))"
        
        if let receiptURLString = expense.receiptURL, let receiptURL = URL(string: receiptURLString) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: receiptURL), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.receiptImageView.image = image
                        self.receiptImageView.isHidden = false // Show only when image loads
                    }
                }
            }
        }
    }
    
    private func formattedDate(from isoDate: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: isoDate) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.string(from: date)
        }
        return isoDate // Fallback if parsing fails
    }
    
    @objc private func viewReceiptFullscreen() {
        guard let image = receiptImageView.image else { return }
        let fullscreenVC = FullscreenImageViewController(image: image)
        present(fullscreenVC, animated: true, completion: nil)
    }
    
    @objc private func editExpense() {
        let editVC = AddEditExpenseViewController(
            categories: categories, // Pass the categories
            participants: participants, // Pass the participants
            travelId: travelId, // Use the travelId directly
            currencySymbol: currencySymbol,
            expense: expense // Pass the current expense
        )
        
        let navController = UINavigationController(rootViewController: editVC)
        present(navController, animated: true, completion: nil)
    }

    @objc private func confirmDeleteExpense() {
        let alert = UIAlertController(
            title: "Delete Expense",
            message: "Are you sure you want to delete this expense? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deleteExpense()
        }))
        
        present(alert, animated: true)
    }

    @objc private func deleteExpense() {
        SpendingFirebaseManager.shared.deleteSpendingItem(
                from: self.expense.categoryId,
                spendingItemId: self.expense.id
            ) { [weak self] success in
                guard let self = self else { return }
                if success {
                    NotificationCenter.default.post(name: .travelDataChanged, object: nil)
                    // Go back to parent view controller
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.showAlert(title: "Error", message: "Failed to delete expense.")
                }
            }
    }
    
    @objc private func handleTravelDataChanged(notification: Notification) {
            guard let userInfo = notification.userInfo,
                  let updatedExpense = userInfo["expense"] as? SpendingItem,
                  updatedExpense.id == self.expense.id else {
                return
            }

            // Refresh the expense details
            self.expense = updatedExpense

            if let updatedCategory = categories.first(where: { $0.id == updatedExpense.categoryId }) {
                self.category = updatedCategory
            }

            if let updatedSpender = participants.first(where: { $0.id == updatedExpense.spentByUserId }) {
                self.spender = updatedSpender
            }

            configureWithExpense() // Update UI
        }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func refreshWithUpdatedData(
        expense: SpendingItem,
        category: Category,
        participants: [User],
        currencySymbol: String,
        travelId: String
    ) {
        // Update all instance variables
        self.expense = expense
        self.category = category
        self.participants = participants
        self.currencySymbol = currencySymbol
        self.travelId = travelId

        // Reconfigure UI with the updated data
        configureWithExpense()
    }
    
    deinit {
        onDeinit?(self)
    }
}
