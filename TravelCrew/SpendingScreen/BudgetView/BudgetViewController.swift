import UIKit

class BudgetViewController: UIViewController {
    
    private var categories: [Category] = []
    private var spendingItems: [SpendingItem] = []
    private var participants: [User] = []
    private var userIcons: [String: UIImage] = [:]
    private var travelPlan: Travel?
    private var totalBudget: Double = 0
    private var currencySymbol: String = "$" // Default to USD
    private var isUpdatingSummary = false
    private var updateSummaryWorkItem: DispatchWorkItem?
    
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
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .travelDataChanged, object: nil)
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
    
    private func sortCategories() {
        // Sort categories alphabetically by name
        categories.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
    
    func setTravelPlan(
        _ travelPlan: Travel,
        categories: [Category],
        spendingItems: [SpendingItem],
        participants: [User],
        currencySymbol: String,
        userIcons: [String: UIImage]
    ) {
        self.travelPlan = travelPlan
        
        print("Categories before updating: \(categories.count)")
        self.categories = categories
        print("Categories after updating: \(self.categories.count)")
        
        self.spendingItems = spendingItems
        self.participants = participants
        self.currencySymbol = currencySymbol
        self.userIcons = userIcons // Pass down user icons
        
        print("[BudgetViewController] Travel plan updated: \(travelPlan.travelTitle). Categories count: \(categories.count). Participants count: \(participants.count). Currency: \(currencySymbol).")
        
        // Sort categories before rendering
        sortCategories()
        calculateSummary()
        
        tableView.reloadData() // Refresh the table
        
        // Update the active BudgetDetailViewController if it exists
        if let detailVC = navigationController?.viewControllers.first(where: { $0 is BudgetDetailViewController }) as? BudgetDetailViewController {
            // Find the category corresponding to the currently active detail view
            if let activeCategory = categories.first(where: { $0.id == detailVC.getCategoryId() }) {
                let filteredSpendingItems = spendingItems.filter { $0.categoryId == activeCategory.id }
                detailVC.updateCategory(activeCategory, spendingItems: filteredSpendingItems, userIcons: userIcons) // Pass userIcons
                detailVC.updateLabels()
            } else {
                print("[BudgetViewController] No matching category found for active BudgetDetailViewController.")
            }
        }
    }
    
    func updateBudgetDetailViewController(with category: Category, spendingItems: [SpendingItem]) {
        if let detailVC = navigationController?.viewControllers.first(where: { $0 is BudgetDetailViewController }) as? BudgetDetailViewController {
            detailVC.updateCategory(category, spendingItems: spendingItems, userIcons: userIcons)
        }
    }
    
    
    private func calculateSummary() {
        print("[calculateSummary] Calculating total budget from categories: \(categories.map { "\($0.name): \($0.budgetAmount)" })")
        let calculatedBudget = categories.reduce(0) { $0 + $1.budgetAmount }
        totalBudget = calculatedBudget
        summaryLabel.text = "Total Budget: \(currencySymbol) \(totalBudget)"
        print("[calculateSummary] Updated total budget to \(totalBudget) \(currencySymbol)")
    }
    
    @objc private func addCategoryTapped() {
        guard let travelPlan = travelPlan else {
            print("Error: travelPlan is nil.")
            return
        }
        
        let addEditVC = BudgetAddEditViewController(
            travelId: travelPlan.id,
            totalBudget: totalBudget,
            currencySymbol: currencySymbol
        )
        addEditVC.modalPresentationStyle = .formSheet
        addEditVC.modalTransitionStyle = .coverVertical
        present(addEditVC, animated: true)
    }
    
    // Handle travel data changes
//    @objc private func handleTravelDataChanged(notification: Notification) {
//        guard let userInfo = notification.userInfo,
//              let travelId = userInfo["travelId"] as? String,
//              travelPlan?.id == travelId else {
//            print("[BudgetViewController] Ignored travel data change for unrelated travel ID.")
//            return
//        }
//        
//        print("[BudgetViewController] Handling travel data change for ID: \(travelId)")
//        SpendingFirebaseManager.shared.fetchTravel(for: travelId) { [weak self] travelPlan in
//            guard let self = self, let travelPlan = travelPlan else { return }
//            DispatchQueue.main.async {
//                self.travelPlan = travelPlan
//                
//                SpendingFirebaseManager.shared.fetchCategoriesByIds(categoryIds: travelPlan.categoryIds) { categories in
//                    DispatchQueue.main.async {
//                        self.categories = categories
//                        // Sort categories before rendering
//                        self.sortCategories()
//                        
//                        self.spendingItems = self.spendingItems.filter { spendingItem in
//                            categories.contains(where: { $0.id == spendingItem.categoryId })
//                        }
//                        self.calculateSummary()
//                        self.tableView.reloadData()
//                        
//                        // Ensure detailVC updates reflect the latest data
//                        if let detailVC = self.navigationController?.viewControllers.first(where: { $0 is BudgetDetailViewController }) as? BudgetDetailViewController {
//                            if let activeCategory = categories.first(where: { $0.id == detailVC.getCategoryId() }) {
//                                let filteredSpendingItems = self.spendingItems.filter { $0.categoryId == activeCategory.id }
//                                detailVC.updateCategory(activeCategory, spendingItems: filteredSpendingItems, userIcons: self.userIcons)
//                                detailVC.updateLabels()
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
    @objc private func handleTravelDataChanged(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let travelId = userInfo["travelId"] as? String,
              let categories = userInfo["categories"] as? [Category],
              travelPlan?.id == travelId else {
            print("[BudgetViewController] Ignored travel data change for unrelated travel ID.")
            return
        }
        
        print("[BudgetViewController] Travel data changed for travel ID: \(travelId)")
        self.categories = categories
        self.calculateSummary()
    }
    
    private func showDeleteConfirmation(for indexPath: IndexPath) {
        guard indexPath.row < categories.count else {
            print("Error: IndexPath.row (\(indexPath.row)) is out of range for categories.count (\(categories.count)).")
            return
        }

        let category = categories[indexPath.row]
        
        // Check if there are any settled spending items in this category
        let settledSpendingItems = spendingItems.filter { $0.categoryId == category.id && $0.isSettled }
        if !settledSpendingItems.isEmpty {
            showAlert(title: "Cannot Delete", message: "This category has settled expenses and cannot be deleted.")
            return
        }
        
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
                        // Ensure indexPath is still valid
                        if indexPath.row < self.categories.count {
                            self.categories.remove(at: indexPath.row)
                            self.sortCategories()
                            
                            // Update the UI
                            self.tableView.deleteRows(at: [indexPath], with: .automatic)
                            
                            // Recalculate the summary
                            self.calculateSummary()
                        } else {
                            print("Error: IndexPath.row (\(indexPath.row)) became invalid after deletion.")
                        }
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
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categories[indexPath.row]
        guard let travelPlan = travelPlan else { return }
        
        let filteredSpendingItems = spendingItems.filter { $0.categoryId == category.id }
        
        if let detailVC = navigationController?.viewControllers.first(where: { $0 is BudgetDetailViewController }) as? BudgetDetailViewController {
            detailVC.updateCategory(category, spendingItems: filteredSpendingItems, userIcons: userIcons) // Pass userIcons here
            navigationController?.popToViewController(detailVC, animated: true)
        } else {
            let detailVC = BudgetDetailViewController(
                category: category,
                spendingItems: filteredSpendingItems,
                participants: participants,
                currencySymbol: currencySymbol,
                travelId: travelPlan.id,
                userIcons: userIcons,
                categories: categories
            )
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            let category = self.categories[indexPath.row]
            guard let travelPlan = self.travelPlan else { return }
            
            // Create and present BudgetAddEditViewController as a modal
            let addEditVC = BudgetAddEditViewController(
                category: category,
                travelId: travelPlan.id,
                totalBudget: self.totalBudget,
                currencySymbol: self.currencySymbol
            )
            addEditVC.modalPresentationStyle = .formSheet
            addEditVC.modalTransitionStyle = .coverVertical
            self.present(addEditVC, animated: true)
            
            completionHandler(true)
        }
        editAction.backgroundColor = .systemBlue
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            self.showDeleteConfirmation(for: indexPath)
            completionHandler(true)
        }
        
        return UISwipeActionsConfiguration(actions: [editAction, deleteAction])
    }
    
}
