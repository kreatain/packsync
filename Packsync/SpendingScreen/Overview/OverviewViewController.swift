//
//  OverviewViewController.swift
//  Packsync
//
//  Created by Xu Yang on 11/11/24.
//

import UIKit

class OverviewViewController: UIViewController {
    
    private let totalBudgetLabel = UILabel()
    private let currentExpensesLabel = UILabel()
    private let categoryTableView = UITableView()
    
    var categories: [Category] = []
    var travelId: String = "example-travel-id" // Replace with the actual travel ID
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        fetchCategoriesData()
    }
    
    private func setupUI() {
        // Total Budget Label
        totalBudgetLabel.font = .boldSystemFont(ofSize: 18)
        totalBudgetLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(totalBudgetLabel)
        
        // Current Expenses Label
        currentExpensesLabel.font = .systemFont(ofSize: 16)
        currentExpensesLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(currentExpensesLabel)
        
        // TableView for category list
        categoryTableView.dataSource = self
        categoryTableView.register(CategoryCell.self, forCellReuseIdentifier: "CategoryCell")
        categoryTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(categoryTableView)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            totalBudgetLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            totalBudgetLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            currentExpensesLabel.topAnchor.constraint(equalTo: totalBudgetLabel.bottomAnchor, constant: 10),
            currentExpensesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            categoryTableView.topAnchor.constraint(equalTo: currentExpensesLabel.bottomAnchor, constant: 20),
            categoryTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoryTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoryTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func fetchCategoriesData() {
        SpendingFirebaseManager.shared.fetchCategories(for: travelId) { [weak self] categories in
            guard let self = self else { return }
            self.categories = categories
            self.calculateAndDisplayBudget()
            self.categoryTableView.reloadData()
        }
    }
    
    private func calculateAndDisplayBudget() {
        let totalBudget = categories.reduce(into: 0) { $0 += $1.budgetAmount }
        var currentExpenses: Double = 0
        let group = DispatchGroup()
        
        for category in categories {
            group.enter()
            
            // Fetch spending items for each category by IDs
            SpendingFirebaseManager.shared.fetchSpendingItems(for: travelId, categoryId: category.id) { spendingItems in
                let categoryTotal = category.calculateTotalSpent(using: spendingItems)
                currentExpenses += categoryTotal
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.totalBudgetLabel.text = "Total Budget: $\(totalBudget)"
            self.currentExpensesLabel.text = "Current Expenses: $\(currentExpenses) (\(self.percentage(of: currentExpenses, outOf: totalBudget))%)"
        }
    }
    
    private func percentage(of value: Double, outOf total: Double) -> Int {
        guard total > 0 else { return 0 }
        return Int((value / total) * 100)
    }
}

// MARK: - UITableViewDataSource
extension OverviewViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        let category = categories[indexPath.row]
        cell.configure(with: category, travelId: travelId, totalBudget: category.budgetAmount)
        return cell
    }
}
