//
//  ExpensesViewController.swift
//  Packsync
//
//  Created by Xu Yang on 11/11/24.
//

import UIKit

class ExpensesViewController: UIViewController {
    private let totalExpenseLabel = UILabel() // Label to display total expenses
    private let tableView = UITableView()
    private let addExpenseButton = UIButton(type: .system)
    
    private var expenses: [SpendingItem] = []
    private var categories: [Category] = []
    private var participants: [User] = []
    private var userIcons: [String: UIImage] = [:]
    private var currencySymbol: String = "$"
    private var travelPlan: Travel?
    private var activeDetailViewControllers: [ExpenseDetailsViewController] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateTotalExpenseLabel() // Update the total expense when the view loads
    }

    private func setupUI() {
        view.backgroundColor = .white
        
        // Total Expense Label setup
        totalExpenseLabel.font = .boldSystemFont(ofSize: 18)
        totalExpenseLabel.textAlignment = .center
        totalExpenseLabel.textColor = .black
        totalExpenseLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(totalExpenseLabel)
        
        // TableView setup
        tableView.register(ExpenseCell.self, forCellReuseIdentifier: "ExpenseCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 75
        view.addSubview(tableView)
        
        // Add Expense Button setup
        addExpenseButton.setTitle("Add Expense", for: .normal)
        addExpenseButton.backgroundColor = .systemBlue
        addExpenseButton.setTitleColor(.white, for: .normal)
        addExpenseButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        addExpenseButton.layer.cornerRadius = 8
        addExpenseButton.addTarget(self, action: #selector(addExpenseButtonTapped), for: .touchUpInside)
        addExpenseButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addExpenseButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            totalExpenseLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            totalExpenseLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            totalExpenseLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            tableView.topAnchor.constraint(equalTo: totalExpenseLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addExpenseButton.topAnchor, constant: -20),

            addExpenseButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addExpenseButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addExpenseButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addExpenseButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    // MARK: - Update Total Expense
    private func updateTotalExpenseLabel() {
        let totalExpense = expenses.reduce(0) { $0 + $1.amount }
        totalExpenseLabel.text = "Total Expenses: \(currencySymbol)  \(String(format: "%.1f", totalExpense))"
    }

    // MARK: - Set Travel Plan
    func setTravelPlan(
        _ travelPlan: Travel,
        categories: [Category],
        spendingItems: [SpendingItem],
        participants: [User],
        currencySymbol: String,
        userIcons: [String: UIImage]
    ) {
        self.travelPlan = travelPlan
        self.categories = categories

        // Sort spending items from new to old
        self.expenses = spendingItems.sorted { item1, item2 in
            guard let date1 = ISO8601DateFormatter().date(from: item1.date),
                  let date2 = ISO8601DateFormatter().date(from: item2.date) else {
                return false
            }
            return date1 > date2 // Descending order: Newest first
        }

        self.participants = participants
        self.currencySymbol = currencySymbol
        self.userIcons = userIcons

        // Refresh the table view
        tableView.reloadData()

        // Update the total expense label
        updateTotalExpenseLabel()

        // Refresh all active details view controllers
        for detailVC in activeDetailViewControllers {
            if let updatedExpense = expenses.first(where: { $0.id == detailVC.expense.id }),
               let updatedCategory = categories.first(where: { $0.id == updatedExpense.categoryId }) {
                detailVC.refreshWithUpdatedData(
                    expense: updatedExpense,
                    category: updatedCategory,
                    participants: participants,
                    currencySymbol: currencySymbol,
                    travelId: travelPlan.id
                )
            } else {
                print("[ExpensesViewController] Failed to find matching data for ExpenseDetailsViewController.")
            }
        }
    }

    @objc private func addExpenseButtonTapped() {
        guard let travelPlan = travelPlan else { return }
        
        let addEditExpenseVC = AddEditExpenseViewController(
            categories: categories,
            participants: participants,
            travelId: travelPlan.id,
            currencySymbol: currencySymbol
        )
        let navController = UINavigationController(rootViewController: addEditExpenseVC)
        present(navController, animated: true, completion: nil)
    }

    
    private func formattedDate(from isoDate: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: isoDate) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.string(from: date)
        }
        return isoDate // Fallback
    }
    
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension ExpensesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        expenses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCell", for: indexPath) as? ExpenseCell else {
            return UITableViewCell()
        }

        let expense = expenses[indexPath.row]
        let category = categories.first { $0.id == expense.categoryId }
        let emoji = category?.emoji ?? "❓"
        let dateString = formattedDate(from: expense.date)

        // Use userIcons dictionary for the user icon
        let userIcon = userIcons[expense.spentByUserId] ?? UIImage(systemName: "person.circle") // Default icon

        // Check if receipt exists
        let hasReceipt = expense.receiptURL != nil && !expense.receiptURL!.isEmpty

        // Check if the expense is settled
        let isSettled = expense.isSettled // Assuming `isSettled` is a Boolean field in `SpendingItem`

        // Configure the cell with updated parameters
        cell.configure(
            with: expense,
            categoryEmoji: emoji,
            userIcon: userIcon,
            dateString: dateString,
            hasReceipt: hasReceipt,
            isSettled: isSettled
        )

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let expense = expenses[indexPath.row]
        guard let category = categories.first(where: { $0.spendingItemIds.contains(expense.id) }) else { return }
        let spender = participants.first(where: { $0.id == expense.spentByUserId })

        guard let travelId = travelPlan?.id else {
            print("Error: Travel ID not found")
            return
        }

        let detailsVC = ExpenseDetailsViewController(
            expense: expense,
            category: category,
            spender: spender,
            currencySymbol: currencySymbol,
            travelId: travelId,
            categories: categories, // Pass categories
            participants: participants // Pass participants
        )
        
        // Add to active controllers
        activeDetailViewControllers.append(detailsVC)
        detailsVC.onDeinit = { [weak self] vc in
            self?.activeDetailViewControllers.removeAll { $0 === vc }
        }
        
        navigationController?.pushViewController(detailsVC, animated: true)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let expense = expenses[indexPath.row]

        if expense.isSettled {
            // Display a gray box with a message for settled expenses
            let settledAction = UIContextualAction(style: .normal, title: "Settled") { _, _, completionHandler in
                // Notify the user that settled expenses are not editable
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

        // Normal swipe actions for non-settled expenses
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            guard let self = self else { return }

            let alert = UIAlertController(title: "Confirm Delete", message: "Are you sure you want to delete this expense?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                let expenseToDelete = self.expenses[indexPath.row]

                guard let category = self.categories.first(where: { $0.spendingItemIds.contains(expenseToDelete.id) }) else {
                    completionHandler(false)
                    return
                }

                guard let travelId = self.travelPlan?.id else {
                    print("Error: Travel ID not found")
                    completionHandler(false)
                    return
                }

                SpendingFirebaseManager.shared.deleteSpendingItem(from: category.id, spendingItemId: expenseToDelete.id, travelId: travelId) { success in
                    if success {
                        self.expenses.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                        self.updateTotalExpenseLabel()
                        NotificationCenter.default.post(name: .travelDataChanged, object: nil)
                    } else {
                        print("Failed to delete expense.")
                    }
                    completionHandler(success)
                }
            })
            self.present(alert, animated: true, completion: nil)
        }

        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            let expenseToEdit = self.expenses[indexPath.row]
            let editExpenseVC = AddEditExpenseViewController(
                categories: self.categories,
                participants: self.participants,
                travelId: self.travelPlan?.id ?? "",
                currencySymbol: self.currencySymbol,
                expense: expenseToEdit
            )
            let navController = UINavigationController(rootViewController: editExpenseVC)
            self.present(navController, animated: true, completion: nil)
            completionHandler(true)
        }

        editAction.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [editAction, deleteAction])
    }
    
    
}
