//
//  BudgetDetailViewController.swift
//  Packsync
//
//  Created by Leo Yang  on 11/18/24.
//


import UIKit

class BudgetDetailViewController: UIViewController {
    private let tableView = UITableView()
    private let addExpenseButton = UIButton(type: .system)
    
    private let totalBudgetLabel = UILabel()
    private let totalExpensesLabel = UILabel()

    private var category: Category
    private var categories: [Category] 
    private var spendingItems: [SpendingItem]
    private var participants: [User]
    private var userIcons: [String: UIImage] = [:]
    private var currencySymbol: String
    private var travelId: String
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .systemBlue
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    init(category: Category, 
         spendingItems: [SpendingItem], 
         participants: [User], 
         currencySymbol: String, 
         travelId: String, 
         userIcons: [String: UIImage], 
         categories: [Category]) { 
        self.category = category
        self.spendingItems = spendingItems
        self.participants = participants
        self.currencySymbol = currencySymbol
        self.travelId = travelId
        self.userIcons = userIcons
        self.categories = categories 
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        filterSpendingItemsByCategory()
    }

    private func setupUI() {
        view.backgroundColor = .white
        title = "\(category.name)"
        
        // Setup Total Budget Label
        totalBudgetLabel.font = .boldSystemFont(ofSize: 18)
        totalBudgetLabel.textAlignment = .left
        totalBudgetLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(totalBudgetLabel)
        
        // Setup Total Expenses Label
        totalExpensesLabel.font = .boldSystemFont(ofSize: 18)
        totalExpensesLabel.textAlignment = .left
        totalExpensesLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(totalExpensesLabel)

        // TableView Setup
        tableView.register(ExpenseCell.self, forCellReuseIdentifier: "ExpenseCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 75
        view.addSubview(tableView)

        // Add Expense Button Setup
        addExpenseButton.setTitle("Add Expense", for: .normal)
        addExpenseButton.backgroundColor = .systemBlue
        addExpenseButton.setTitleColor(.white, for: .normal)
        addExpenseButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        addExpenseButton.layer.cornerRadius = 8
        addExpenseButton.addTarget(self, action: #selector(addExpenseTapped), for: .touchUpInside)
        addExpenseButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addExpenseButton)
        
        // Loading Indicator Setup
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)

        // Constraints
            NSLayoutConstraint.activate([
                totalBudgetLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
                totalBudgetLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                totalBudgetLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

                totalExpensesLabel.topAnchor.constraint(equalTo: totalBudgetLabel.bottomAnchor, constant: 5),
                totalExpensesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                totalExpensesLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

                tableView.topAnchor.constraint(equalTo: totalExpensesLabel.bottomAnchor, constant: 10),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: addExpenseButton.topAnchor, constant: -10),
                
                // Add Expense Button Constraints
                addExpenseButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                addExpenseButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                addExpenseButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                addExpenseButton.heightAnchor.constraint(equalToConstant: 44),

                // Loading Indicator Constraints
                loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
    }

    @objc private func addExpenseTapped() {
        let addEditExpenseVC = AddEditExpenseViewController(
            categories: [], // Pass an empty array since the category is fixed
            participants: participants,
            travelId: travelId,
            currencySymbol: currencySymbol,
            fixedCategory: category // Specify the fixed category
        )
        let navController = UINavigationController(rootViewController: addEditExpenseVC)
        present(navController, animated: true)
    }

    
    func updateCategory(_ category: Category, spendingItems: [SpendingItem], userIcons: [String: UIImage]) {
        loadingIndicator.startAnimating() // Show the spinner

        DispatchQueue.global(qos: .userInitiated).async {
            self.category = category
            self.spendingItems = spendingItems.sorted { $0.date > $1.date } // Sort by date
            self.userIcons = userIcons // Update user icons

            DispatchQueue.main.async {
                self.title = "\(category.emoji) \(category.name)"
                self.tableView.reloadData()
                self.updateLabels() // Refresh labels here
                self.loadingIndicator.stopAnimating() // Hide the spinner
            }
        }
    }
    
    func getCategoryId() -> String {
        return category.id
    }
    
    func updateLabels() {
            // Compute totals
            let totalBudget = category.budgetAmount
            let totalExpenses = spendingItems.reduce(0) { $0 + $1.amount }
            let percentage = totalBudget > 0 ? (totalExpenses / totalBudget * 100) : 0

            // Update labels
            totalBudgetLabel.text = "Total Budget: \(currencySymbol) \(totalBudget)"
            totalExpensesLabel.text = "Total Expenses: \(currencySymbol) \(totalExpenses) (\(String(format: "%.0f", percentage))%)"
        }
    
    private func filterSpendingItemsByCategory() {
        loadingIndicator.startAnimating() // Show the spinner

        DispatchQueue.global(qos: .userInitiated).async {
            // Simulate processing time for filtering and sorting
            self.spendingItems = self.spendingItems
                .filter { $0.categoryId == self.category.id }
                .sorted { $0.date > $1.date } // Newest first

            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.loadingIndicator.stopAnimating() // Hide the spinner
            }
        }
    }

    private func deleteExpense(at indexPath: IndexPath) {
        guard indexPath.row < spendingItems.count else {
            print("[BudgetDetailViewController] Invalid indexPath for deletion: \(indexPath.row)")
            return
        }

        loadingIndicator.startAnimating() // Show the spinner

        let expenseToDelete = spendingItems[indexPath.row]
        SpendingFirebaseManager.shared.deleteSpendingItem(from: category.id, spendingItemId: expenseToDelete.id, travelId: travelId) { success in
            DispatchQueue.main.async {
                if success {
                    // Remove the deleted expense from the spendingItems array
                    self.spendingItems.remove(at: indexPath.row)
                    // Update the table view to reflect the deletion
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    // Refresh the total budget and expenses labels
                    self.updateLabels()
                    // Post a notification to inform other views of the change
                    NotificationCenter.default.post(name: .travelDataChanged, object: nil)
                } else {
                    // Show an error alert if deletion failed
                    self.showAlert(title: "Error", message: "Failed to delete the expense.")
                }
                // Stop the spinner in either case
                self.loadingIndicator.stopAnimating()
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension BudgetDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("[BudgetDetailViewController] Number of rows in table: \(spendingItems.count)")
        return spendingItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCell", for: indexPath) as? ExpenseCell else {
            return UITableViewCell()
        }

        let expense = spendingItems[indexPath.row]
        let userIcon = userIcons[expense.spentByUserId] ?? UIImage(systemName: "person.circle") // Default icon
        let dateString = formattedDate(from: expense.date)
        
        // Check if the expense has a receipt
        let hasReceipt = expense.receiptURL != nil && !expense.receiptURL!.isEmpty
        
        // Configure the cell with settlement status
        cell.configure(
            with: expense,
            categoryEmoji: category.emoji,
            userIcon: userIcon,
            dateString: dateString,
            hasReceipt: hasReceipt,
            isSettled: expense.isSettled
        )

        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        indexPath.row < spendingItems.count
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        print("[BudgetDetailViewController] Swipe action requested for row: \(indexPath.row)")
        print("[BudgetDetailViewController] Current spendingItems count: \(spendingItems.count)")

        // Validate index
        guard indexPath.row < spendingItems.count else {
            print("[BudgetDetailViewController] Invalid indexPath for swipe action: \(indexPath.row)")
            return nil
        }

        let expense = spendingItems[indexPath.row]

        if expense.isSettled {
            // Display a gray "Settled" action with an alert notification
            let settledAction = UIContextualAction(style: .normal, title: "Settled") { [weak self] _, _, completionHandler in
                guard let self = self else {
                    completionHandler(false)
                    return
                }
                // Show alert notifying that settled expenses cannot be edited or deleted
                let alert = UIAlertController(
                    title: "Settled Expense",
                    message: "This expense has been settled and cannot be edited or deleted.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                completionHandler(true)
            }
            settledAction.backgroundColor = .lightGray
            return UISwipeActionsConfiguration(actions: [settledAction])
        }

        // Regular swipe actions for non-settled expenses
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            guard let self = self else {
                completionHandler(false)
                return
            }

            let alert = UIAlertController(title: "Confirm Delete", message: "Are you sure you want to delete this expense?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completionHandler(false) // User canceled
            })
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                self.deleteExpense(at: indexPath)
                completionHandler(true)
            })
            self.present(alert, animated: true)
        }

        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, completionHandler in
            guard let self = self else {
                completionHandler(false)
                return
            }

            let expenseToEdit = self.spendingItems[indexPath.row]
            let editVC = AddEditExpenseViewController(
                categories: [self.category],
                participants: self.participants,
                travelId: self.travelId,
                currencySymbol: self.currencySymbol,
                expense: expenseToEdit
            )
            let navController = UINavigationController(rootViewController: editVC)
            self.present(navController, animated: true)
            completionHandler(true)
        }
        editAction.backgroundColor = .systemBlue

        return UISwipeActionsConfiguration(actions: [editAction, deleteAction])
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < spendingItems.count else {
            print("[BudgetDetailViewController] Invalid indexPath in didSelectRow: \(indexPath.row)")
            return
        }

        let expense = spendingItems[indexPath.row]
        let spender = participants.first(where: { $0.id == expense.spentByUserId })

        let detailVC = ExpenseDetailsViewController(
            expense: expense,
            category: category,
            spender: spender,
            currencySymbol: currencySymbol,
            travelId: travelId,       // Pass the travelId
            categories: categories,   // Pass the categories
            participants: participants // Pass the participants
        )
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
