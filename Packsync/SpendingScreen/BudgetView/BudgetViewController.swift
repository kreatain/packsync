//
//  BudgetViewController.swift
//  Packsync
//
//  Created by Xu Yang on 11/11/24.
//

import UIKit

class BudgetViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var categories = [Category]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchBudgetCategories()
    }
    
    private func fetchBudgetCategories() {
        SpendingFirebaseManager.shared.fetchBudgetCategories(tripId: "tripId") { [weak self] categories in
            guard let self = self else { return }
            self.categories = categories
            self.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource and UITableViewDelegate
extension BudgetViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.name
        cell.detailTextLabel?.text = "Budget: \(category.budgetAmount), Spent: \(category.spendingItems.reduce(0) { $0 + $1.amount })"
        return cell
    }
}
