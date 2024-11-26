//
//  CurrentBalanceViewController.swift
//  Packsync
//
//  Created by Leo Yang on 11/20/24.
//

import UIKit

class CurrentBalanceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - UI Elements
    private let tableView = UITableView()
    private let unsettledExpenseLabel = UILabel()
    private let settleBalanceButton = UIButton(type: .system)
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let noDataLabel = UILabel()
    
    // MARK: - Properties
    private var travelPlan: Travel?
    private var participants: [User] = []
    private var currentBalance: Balance?
    private var unsettledSpendingItems: [SpendingItem] = []
    private var transactions: [(debtor: User, creditor: User, amount: Double)] = []
    private var userIcons: [String: UIImage] = [:] 
    private var currencySymbol: String = "$"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        showLoading()
        calculateTransactions()
    }
    
    // MARK: - Configuration
    func configure(
        travelPlan: Travel?,
        participants: [User],
        currentBalance: Balance?,
        unsettledSpendingItems: [SpendingItem],
        settledSpendingItems: [SpendingItem], 
        userIcons: [String: UIImage],
        currencySymbol: String
    ) {
        self.travelPlan = travelPlan
        self.participants = participants
        self.currentBalance = currentBalance
        self.unsettledSpendingItems = unsettledSpendingItems
        self.userIcons = userIcons 
        self.currencySymbol = currencySymbol

        let totalExpenses = unsettledSpendingItems.reduce(0) { $0 + $1.amount } +
                            settledSpendingItems.reduce(0) { $0 + $1.amount }
        let unsettledAmount = unsettledSpendingItems.reduce(0) { $0 + $1.amount }
        let percentage = totalExpenses > 0 ? (unsettledAmount / totalExpenses) * 100 : 0

        unsettledExpenseLabel.text = "Unsettled Expenses: \(currencySymbol) \(String(format: "%.1f", unsettledAmount)) (\(String(format: "%.0f", percentage))%)"

        calculateTransactions()
        updateUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        // Unsettled Expense Label
        unsettledExpenseLabel.font = .boldSystemFont(ofSize: 18)
        unsettledExpenseLabel.textAlignment = .center
        unsettledExpenseLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(unsettledExpenseLabel)
        
        // TableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TransactionCell.self, forCellReuseIdentifier: "TransactionCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Settle Balance Button
        settleBalanceButton.setTitle("Settle Balance", for: .normal)
        settleBalanceButton.setTitleColor(.white, for: .normal)
        settleBalanceButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        settleBalanceButton.backgroundColor = .systemBlue
        settleBalanceButton.layer.cornerRadius = 8
        settleBalanceButton.addTarget(self, action: #selector(settleBalance), for: .touchUpInside)
        settleBalanceButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(settleBalanceButton)
        
        // Loading Indicator
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
        
        // No Data Label
        noDataLabel.text = "No transactions to display."
        noDataLabel.textAlignment = .center
        noDataLabel.font = .systemFont(ofSize: 16)
        noDataLabel.textColor = .gray
        noDataLabel.isHidden = true
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noDataLabel)
        
        // Constraints
        NSLayoutConstraint.activate([
            unsettledExpenseLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            unsettledExpenseLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            unsettledExpenseLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: unsettledExpenseLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: settleBalanceButton.topAnchor, constant: -16),
            
            settleBalanceButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            settleBalanceButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            settleBalanceButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            settleBalanceButton.heightAnchor.constraint(equalToConstant: 44),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            noDataLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noDataLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Loading State
    private func showLoading() {
        loadingIndicator.startAnimating()
        tableView.isHidden = true
        noDataLabel.isHidden = true
        settleBalanceButton.isHidden = true
    }
    
    private func hideLoading() {
        loadingIndicator.stopAnimating()
    }
    
    // MARK: - Update UI
    private func updateUI() {
        hideLoading()
        
        // Calculate unsettled amount from unsettledSpendingItems
        let unsettledAmount = unsettledSpendingItems.reduce(0) { $0 + $1.amount }
        
        // Show or hide the settle balance button based on unsettled amount
        settleBalanceButton.isHidden = unsettledAmount == 0
        
        // Show or hide no data label and table view based on transactions
        noDataLabel.isHidden = !transactions.isEmpty
        tableView.isHidden = transactions.isEmpty
        
        // Reload table view if there are transactions
        if !transactions.isEmpty {
            tableView.reloadData()
        }
    }
    
    // MARK: - Transactions Calculation
    private func calculateTransactions() {
        transactions = []
        guard let balance = currentBalance else { return }
        
        // Convert dictionary to array of tuples for processing
        var debtors = balance.balances.filter { $0.value < 0 }.map { ($0.key, $0.value) }
        var creditors = balance.balances.filter { $0.value > 0 }.map { ($0.key, $0.value) }
        
        // Process debtors and creditors
        while !debtors.isEmpty && !creditors.isEmpty {
            guard let debtorEntry = debtors.popLast(), let creditorEntry = creditors.popLast() else { break }
            
            let amountToSettle = min(abs(debtorEntry.1), creditorEntry.1)
            if let debtor = participants.first(where: { $0.id == debtorEntry.0 }),
               let creditor = participants.first(where: { $0.id == creditorEntry.0 }) {
                transactions.append((debtor: debtor, creditor: creditor, amount: amountToSettle))
            }
            
            let debtorRemaining = debtorEntry.1 + amountToSettle
            let creditorRemaining = creditorEntry.1 - amountToSettle
            
            if debtorRemaining < 0 {
                debtors.append((debtorEntry.0, debtorRemaining))
            }
            if creditorRemaining > 0 {
                creditors.append((creditorEntry.0, creditorRemaining))
            }
        }
        
        updateUI()
    }
    
    // MARK: - Settle Balance
    @objc private func settleBalance() {
        guard let travelPlan = travelPlan, let currentBalance = currentBalance else {
            print("[CurrentBalanceViewController] No travel plan or current balance available.")
            return
        }
        
        let balanceId = currentBalance.id
        let travelId = travelPlan.id
        
        print("[CurrentBalanceViewController] Initiating balance settlement for Balance ID: \(balanceId) in Travel Plan ID: \(travelId).")
        
        // Call SpendingFirebaseManager to settle the balance
        SpendingFirebaseManager.shared.settleBalance(for: balanceId, travelId: travelId) { [weak self] success in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if success {
                    print("[CurrentBalanceViewController] Balance settlement successful for Balance ID: \(balanceId).")
                    
                    // Notify the user about the successful settlement
                    let alert = UIAlertController(
                        title: "Settlement Successful",
                        message: "The balance has been successfully settled.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        // Notify the system to refresh data
                        NotificationCenter.default.post(name: .travelDataChanged, object: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    print("[CurrentBalanceViewController] Balance settlement failed for Balance ID: \(balanceId).")
                    
                    // Notify the user about the failure
                    let alert = UIAlertController(
                        title: "Settlement Failed",
                        message: "An error occurred while settling the balance. Please try again.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Check if indexPath is valid
        guard indexPath.row < transactions.count else {
            print("Error: IndexPath.row (\(indexPath.row)) is out of range for transactions.count (\(transactions.count)).")
            return UITableViewCell() // Return an empty cell to avoid crash
        }

        // Retrieve and configure the cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as? TransactionCell else {
            print("Error: Could not dequeue reusable cell with identifier 'TransactionCell'.")
            return UITableViewCell()
        }

        let transaction = transactions[indexPath.row]
        let debtorIcon = userIcons[transaction.debtor.id]
        let creditorIcon = userIcons[transaction.creditor.id]

        cell.configure(with: transaction, debtorIconImage: debtorIcon, creditorIconImage: creditorIcon)
        return cell
    }
    
}
