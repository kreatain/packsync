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
    private var currencySymbol: String = "$"
    private var travelPlan: Travel?

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
        currencySymbol: String
    ) {
        self.travelPlan = travelPlan
        self.categories = categories
        self.expenses = spendingItems
        self.participants = participants
        self.currencySymbol = currencySymbol
        
        tableView.reloadData()
        updateTotalExpenseLabel() // Update the total expense label when setting the travel plan
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

    private func getUserIcon(forUserId userId: String, completion: @escaping (UIImage?) -> Void) {
        // Try to find the user by ID in the participants array
        if let user = participants.first(where: { $0.id == userId }) {
            if let profilePicURL = user.profilePicURL, let url = URL(string: profilePicURL) {
                // Asynchronous fetch using URLSession
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            completion(image)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(UIImage(systemName: "person.circle")) // Placeholder if image fails to load
                        }
                    }
                }.resume()
                return
            }
        }
        // Return placeholder if user or profilePicURL is not found
        completion(UIImage(systemName: "person.circle"))
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

        cell.configure(with: expense, categoryEmoji: emoji, userIcon: UIImage(systemName: "person.circle"), dateString: dateString)

        getUserIcon(forUserId: expense.spentByUserId) { userIcon in
            if let currentIndexPath = tableView.indexPath(for: cell), currentIndexPath == indexPath {
                cell.configure(with: expense, categoryEmoji: emoji, userIcon: userIcon, dateString: dateString)
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let expense = expenses[indexPath.row]
        guard let category = categories.first(where: { $0.spendingItemIds.contains(expense.id) }) else { return }
        let spender = participants.first(where: { $0.id == expense.spentByUserId })
        
        let detailsVC = ExpenseDetailsViewController(
            expense: expense,
            category: category,
            spender: spender,
            currencySymbol: currencySymbol // Pass the currency symbol from parent VC
        )
        navigationController?.pushViewController(detailsVC, animated: true)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
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
                
                SpendingFirebaseManager.shared.deleteSpendingItem(from: category.id, spendingItemId: expenseToDelete.id) { success in
                    if success {
                        self.expenses.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                        self.updateTotalExpenseLabel()
                        
                        // Notify parent view controller about deletion
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
