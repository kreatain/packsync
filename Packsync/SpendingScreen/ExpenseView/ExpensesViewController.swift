//
//  ExpensesViewController.swift
//  Packsync
//
//  Created by Xu Yang on 11/11/24.
//

import UIKit

class ExpensesViewController: UIViewController {
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
    }

    private func setupUI() {
        view.backgroundColor = .white
        
        // TableView setup
        tableView.register(ExpenseCell.self, forCellReuseIdentifier: "ExpenseCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Add Expense Button setup
        addExpenseButton.setTitle("Add Expense", for: .normal)
        addExpenseButton.backgroundColor = .systemBlue
        addExpenseButton.setTitleColor(.white, for: .normal)
        addExpenseButton.layer.cornerRadius = 8
        addExpenseButton.addTarget(self, action: #selector(addExpenseButtonTapped), for: .touchUpInside)
        addExpenseButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addExpenseButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addExpenseButton.topAnchor, constant: -10),
            
            addExpenseButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addExpenseButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addExpenseButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            addExpenseButton.heightAnchor.constraint(equalToConstant: 44)
        ])
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
    }

    @objc private func addExpenseButtonTapped() {
        guard let travelPlan = travelPlan else { return }
        
        let addEditExpenseVC = AddEditExpenseViewController(categories: categories, participants: participants, travelId: travelPlan.id)
        let navController = UINavigationController(rootViewController: addEditExpenseVC)
        present(navController, animated: true, completion: nil)
    }

    private func getUserIcon(forUserId userId: String) -> UIImage? {
        // Try to find the user by ID in the participants array
        if let user = participants.first(where: { $0.id == userId }) {
            if let profilePicURL = user.profilePicURL, let url = URL(string: profilePicURL) {
                // Fetch the image from the URL (can use a caching library like SDWebImage)
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    return image
                }
            }
            return UIImage(systemName: "person.circle") // Placeholder if no profile pic URL
        }
        return UIImage(systemName: "person.circle") // Default placeholder if user not found
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
        let category = categories.first { $0.spendingItemIds.contains(expense.id) }
        let emoji = category?.emoji ?? "❓"
        let userIcon = getUserIcon(forUserId: expense.spentByUserId)

        cell.configure(with: expense, categoryEmoji: emoji, userIcon: userIcon)
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let expenseToDelete = expenses[indexPath.row]
            guard let category = categories.first(where: { $0.spendingItemIds.contains(expenseToDelete.id) }) else {
                return
            }

            SpendingFirebaseManager.shared.deleteSpendingItem(from: category.id, spendingItemId: expenseToDelete.id) { success in
                if success {
                    self.expenses.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                } else {
                    print("Failed to delete expense.")
                }
            }
        }
    }
}
