import UIKit

class BudgetViewController: UIViewController {
    
    private var categories: [Category] = []
    private var travelPlan: Travel?
    private var totalBudget: Double = 0
    private var currencySymbol: String = "$" // Default to USD
    
    private let summaryLabel = UILabel()
    private let tableView = UITableView()
    private let addButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if travelPlan == nil {
            fatalError("travelPlan is nil. Ensure it is set before loading the view.")
        }
        
        tableView.rowHeight = 100
        setupUI()
        configureWithTravelPlan()
        
        // Add observer for travel data changes
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleTravelDataChanged),
                name: .travelDataChanged,
                object: nil
            )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("TableView frame: \(tableView.frame)")
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Summary Label Setup
        summaryLabel.font = .boldSystemFont(ofSize: 18)
        summaryLabel.textAlignment = .center
        summaryLabel.numberOfLines = 0
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(summaryLabel)

        
        // Table View Setup
        tableView.register(CategoryCell.self, forCellReuseIdentifier: "CategoryCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Add Button Setup
        addButton.setTitle("Add New", for: .normal)
        addButton.backgroundColor = .systemBlue
        addButton.setTitleColor(.white, for: .normal)
        addButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        addButton.layer.cornerRadius = 8
        addButton.addTarget(self, action: #selector(addCategoryTapped), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addButton)

        // Constraints
        NSLayoutConstraint.activate([
            summaryLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            summaryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            summaryLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            tableView.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -20),

            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func configureWithTravelPlan() {
        calculateSummary()
        tableView.reloadData()
    }
    
    func setTravelPlan(_ travelPlan: Travel, categories: [Category], currencySymbol: String) {
        self.travelPlan = travelPlan
        self.categories = categories
        self.currencySymbol = currencySymbol

        print("[BudgetViewController] Travel plan updated: \(travelPlan.travelTitle). Categories count: \(categories.count). Currency: \(currencySymbol).")
    
        tableView.reloadData() // Refresh the table
    }
    
    private func calculateSummary() {
           totalBudget = categories.reduce(0) { $0 + $1.budgetAmount }
           summaryLabel.text = "Total Budget: \(currencySymbol)\(totalBudget)"
       }
    
    @objc private func addCategoryTapped() {
        guard let travelPlan = travelPlan else {
            print("Error: travelPlan is nil.")
            return
        }
        let addEditVC = BudgetAddEditViewController(travelId: travelPlan.id, totalBudget: totalBudget)
        navigationController?.pushViewController(addEditVC, animated: true)
        
        // Notify that travel data has changed
        NotificationCenter.default.post(name: .travelDataChanged, object: nil)
    }
    
    // Handle travel data changes
    @objc private func handleTravelDataChanged(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let travelId = userInfo["travelId"] as? String,
              travelPlan?.id == travelId else {
            return
        }

        print("[BudgetViewController] Handling travel data change notification.")

        // Fetch the latest travel plan to synchronize category IDs
        SpendingFirebaseManager.shared.fetchTravel(for: travelId) { [weak self] travelPlan in
            guard let self = self, let travelPlan = travelPlan else { return }
            DispatchQueue.main.async {
                // Update the local travelPlan and category IDs
                self.travelPlan = travelPlan

                // Fetch updated categories
                SpendingFirebaseManager.shared.fetchCategoriesByIds(categoryIds: travelPlan.categoryIds) { categories in
                    DispatchQueue.main.async {
                        self.categories = categories
                        self.calculateSummary()
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    private func showDeleteConfirmation(for indexPath: IndexPath) {
        let category = categories[indexPath.row]
        let alert = UIAlertController(
            title: "Confirm Deletion",
            message: "Are you sure you want to delete the category '\(category.name)'? This will also delete all associated spending items.",
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self, let travelPlan = self.travelPlan else { return }

            SpendingFirebaseManager.shared.deleteCategory(from: travelPlan.id, categoryId: category.id) { success in
                if success {
                    DispatchQueue.main.async {
                        // Update the data source first
                        self.categories.remove(at: indexPath.row)
                        
                        // Update the UI
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                        
                        // Recalculate the summary
                        self.calculateSummary()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: "Failed to delete the category. Please try again.")
                    }
                }
            }
        }

        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension BudgetViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of categories: \(categories.count)")
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Configuring cell for row \(indexPath.row)")
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as? CategoryCell else {
            fatalError("Failed to dequeue CategoryCell")
        }
        let category = categories[indexPath.row]
        print("Category for row \(indexPath.row): \(category.name)")
        cell.configure(with: category, currencySymbol: currencySymbol, displayProgressBar: true)
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            let category = self.categories[indexPath.row]
            guard let travelPlan = self.travelPlan else { return }
            let addEditVC = BudgetAddEditViewController(category: category, travelId: travelPlan.id, totalBudget: self.totalBudget)
            self.navigationController?.pushViewController(addEditVC, animated: true)
            completionHandler(true)
        }
        editAction.backgroundColor = .systemBlue

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            self.showDeleteConfirmation(for: indexPath)
            completionHandler(true)
        }

        return UISwipeActionsConfiguration(actions: [editAction, deleteAction])
    }
}
