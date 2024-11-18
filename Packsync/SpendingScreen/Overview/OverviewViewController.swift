import UIKit
import DGCharts


class OverviewViewController: UIViewController {
    private let summaryLabel = UILabel()
    private let pieChartView = PieChartView()
    
    private var categories: [Category] = []
    private var spendingItems: [SpendingItem] = []
    private var travelPlan: Travel?
    private var currencySymbol: String = "$"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        
        if travelPlan != nil {
            setupViewWithTravelPlan()
        }
        
        // Add observer for travel data changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTravelDataChanged),
            name: .travelDataChanged,
            object: nil
        )
    }
    
    private func setupUI() {
        // Summary Label
        summaryLabel.font = .boldSystemFont(ofSize: 18)
        summaryLabel.textAlignment = .center
        summaryLabel.numberOfLines = 0
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(summaryLabel)
        
        // Pie Chart View
        pieChartView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pieChartView)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            summaryLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            summaryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            summaryLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            pieChartView.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 20),
            pieChartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            pieChartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            pieChartView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    func setTravelPlan(
        _ travelPlan: Travel,
        categories: [Category],
        spendingItems: [SpendingItem],
        participants: [User],
        currencySymbol: String
    ) {
        self.travelPlan = travelPlan
        self.categories = categories
        self.spendingItems = spendingItems
        self.currencySymbol = currencySymbol
        
        print("[OverviewViewController] Travel plan updated: \(travelPlan.travelTitle). Categories count: \(categories.count). Currency: \(currencySymbol).")
        setupViewWithTravelPlan()
    }
    
    private func setupViewWithTravelPlan() {
        guard let travelPlan = travelPlan else {
            print("OverviewVC: No travel plan set to configure the view.")
            return
        }
        
        print("OverviewVC: Configuring view with travel plan details:")
        print("""
        Travel Plan Details:
        - ID: \(travelPlan.id)
        - Title: \(travelPlan.travelTitle)
        - Number of Categories: \(categories.count)
        """)
        
        // Update summary label
        calculateAndDisplaySummary()
        
        // Update pie chart
        updatePieChart()
    }
    
    private func calculateAndDisplaySummary() {
        let totalBudget = categories.reduce(0) { $0 + $1.budgetAmount }
        let totalExpenses = categories.reduce(0) { $0 + $1.calculateTotalSpent(using: spendingItems) }
        let percentage = totalBudget > 0 ? (totalExpenses / totalBudget * 100) : 0
        
        summaryLabel.text = """
        Total Budget: \(currencySymbol)\(totalBudget)
        Total Expenses: \(currencySymbol)\(totalExpenses) (\(String(format: "%.1f", percentage))%)
        """
    }
    
    private func updatePieChart() {
        guard categories.count > 0 else {
            pieChartView.data = nil
            return
        }
        
        let totalBudget = categories.reduce(0) { $0 + $1.budgetAmount }
        
        var entries: [PieChartDataEntry] = []
        var colors: [UIColor] = []
        
        for category in categories {
            let categoryBudget = category.budgetAmount
            let spentAmount = category.calculateTotalSpent(using: spendingItems)
            let remainingAmount = max(categoryBudget - spentAmount, 0)
            
            // Add spent entry
            if spentAmount > 0 {
                let spentEntry = PieChartDataEntry(value: spentAmount, label: "\(category.name) (Spent)")
                entries.append(spentEntry)
                colors.append(.systemBlue) // Dark color for spent
            }
            
            // Add remaining entry
            if remainingAmount > 0 {
                let remainingEntry = PieChartDataEntry(value: remainingAmount, label: "\(category.name) (Remaining)")
                entries.append(remainingEntry)
                colors.append(.systemBlue.withAlphaComponent(0.5)) // Light color for remaining
            }
        }
        
        // Configure data set
        let dataSet = PieChartDataSet(entries: entries, label: "")
        dataSet.colors = colors
        dataSet.sliceSpace = 2.0
        
        // Configure pie chart data
        let data = PieChartData(dataSet: dataSet)
        data.setValueTextColor(.black) // Set text inside the pie chart to black
        data.setValueFont(.systemFont(ofSize: 12, weight: .bold))
        
        // Update pie chart
        pieChartView.data = data
        pieChartView.notifyDataSetChanged()
    }
    
    @objc private func handleTravelDataChanged(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let travelId = userInfo["travelId"] as? String,
              travelPlan?.id == travelId else {
            return
        }
        
        print("[OverviewViewController] Handling travel data change notification.")
        
        // Fetch updated categories and refresh UI
        SpendingFirebaseManager.shared.fetchCategoriesByIds(categoryIds: travelPlan?.categoryIds ?? []) { [weak self] categories in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.categories = categories
                self.calculateAndDisplaySummary()
                self.updatePieChart()
            }
        }
    }
}
