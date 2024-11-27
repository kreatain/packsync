//
//  SettledExpensesViewController.swift
//  Packsync
//

import UIKit

class SettledExpensesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UI Elements
    private let tableView = UITableView()
    private let noDataLabel = UILabel() 
    private let totalSettledLabel = UILabel()
    
    // MARK: - Properties
    private var settledSpendingItems: [SpendingItem] = []
    private var categories: [Category] = []
    private var participants: [User] = []
    private var userIcons: [String: UIImage] = [:]
    private var currencySymbol: String = "$"
    private var travelId: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateNoDataLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Configuration
    func configure(
        settledSpendingItems: [SpendingItem],
        unsettledSpendingItems: [SpendingItem], // Accept unsettled spending items
        categories: [Category],
        participants: [User],
        currencySymbol: String,
        userIcons: [String: UIImage],
        travelId: String
    ) {
        self.settledSpendingItems = settledSpendingItems
        self.categories = categories
        self.participants = participants
        self.currencySymbol = currencySymbol
        self.userIcons = userIcons
        self.travelId = travelId

        let totalExpenses = unsettledSpendingItems.reduce(0) { $0 + $1.amount } +
                            settledSpendingItems.reduce(0) { $0 + $1.amount }
        let settledAmount = settledSpendingItems.reduce(0) { $0 + $1.amount }
        let percentage = totalExpenses > 0 ? (settledAmount / totalExpenses) * 100 : 0

        totalSettledLabel.text = "Settled Expenses: \(currencySymbol) \(String(format: "%.1f", settledAmount)) (\(String(format: "%.0f", percentage))%)"

        updateUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        // Total Settled Label
            totalSettledLabel.font = .boldSystemFont(ofSize: 18)
            totalSettledLabel.textAlignment = .center
            totalSettledLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(totalSettledLabel)
        
        // No Data Label
        noDataLabel.text = "No settled expenses to display."
        noDataLabel.font = .systemFont(ofSize: 16)
        noDataLabel.textColor = .gray
        noDataLabel.textAlignment = .center
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noDataLabel)
        
        // TableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80
        tableView.register(ExpenseCell.self, forCellReuseIdentifier: "ExpenseCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Constraints
        NSLayoutConstraint.activate([
                totalSettledLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
                totalSettledLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                totalSettledLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                
                noDataLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                noDataLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                
                tableView.topAnchor.constraint(equalTo: totalSettledLabel.bottomAnchor, constant: 16),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
    }
    
    // MARK: - Update No Data Label
    private func updateNoDataLabel() {
        noDataLabel.isHidden = !settledSpendingItems.isEmpty
        tableView.isHidden = settledSpendingItems.isEmpty
    }
    
    func updateUI() {
        noDataLabel.isHidden = !settledSpendingItems.isEmpty
        tableView.isHidden = settledSpendingItems.isEmpty
        
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settledSpendingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCell", for: indexPath) as? ExpenseCell else {
            return UITableViewCell()
        }

        let expense = settledSpendingItems[indexPath.row]
        print("[CellForRowAt] Configuring cell for Expense ID: \(expense.id)")

        // Log categories and attempt to find the matching category
        print("[CellForRowAt] Categories available: \(categories.map { $0.id })")
        let category = categories.first { $0.id == expense.categoryId }

        // Get category emoji or fallback
        let emoji = category?.emoji ?? "❓"

        // Log userIcons and attempt to find the user icon
        print("[CellForRowAt] User icons available: \(userIcons.keys)")
        let userIcon = userIcons[expense.spentByUserId] ?? UIImage(systemName: "person.circle")
        if userIcons[expense.spentByUserId] == nil {
            print("[CellForRowAt] No user icon found for User ID: \(expense.spentByUserId)")
        }

        // Log receipt presence
        let hasReceipt = expense.receiptURL != nil && !expense.receiptURL!.isEmpty
        print("[CellForRowAt] Receipt \(hasReceipt ? "available" : "not available") for Expense ID: \(expense.id)")

        // Determine if the expense is settled
        let isSettled = expense.isSettled // Assuming this field exists in `SpendingItem`

        // Configure the cell
        cell.configure(
            with: expense,
            categoryEmoji: emoji,
            userIcon: userIcon,
            dateString: formattedDate(from: expense.date),
            hasReceipt: hasReceipt,
            isSettled: isSettled
        )

        print("[CellForRowAt] Configured cell for Expense ID: \(expense.id) with settled status: \(isSettled)")

        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let expense = settledSpendingItems[indexPath.row]
        print("[DidSelectRowAt] Selected Expense ID: \(expense.id)")
        
        guard let category = categories.first(where: { $0.spendingItemIds.contains(expense.id) }) else {
            print("[DidSelectRowAt] No category found for Expense ID: \(expense.id)")
            return
        }
        print("[DidSelectRowAt] Found category \(category.name) for Expense ID: \(expense.id)")
        
        let spender = participants.first(where: { $0.id == expense.spentByUserId })
        
        guard let travelId = travelId else {
            print("[DidSelectRowAt] Travel ID not found")
            return
        }
        print("[DidSelectRowAt] Navigating to details with Travel ID: \(travelId)")
        
        let detailsVC = ExpenseDetailsViewController(
            expense: expense,
            category: category,
            spender: spender,
            currencySymbol: currencySymbol,
            travelId: travelId,
            categories: categories,
            participants: participants
        )
        
        navigationController?.pushViewController(detailsVC, animated: true)
    }
    
    // MARK: - Date Formatting
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
