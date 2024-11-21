import UIKit
import DGCharts

class OverviewViewController: UIViewController, ChartViewDelegate {
    private let totalBudgetLabel = UILabel()
    private let totalBudgetPieChartView = PieChartView()
    private let totalExpensesLabel = UILabel()
    private let totalExpensesPieChartView = PieChartView()
    private let totalBudgetEmptyLabel = UILabel()
    private let totalExpensesEmptyLabel = UILabel()

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

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTravelDataChanged),
            name: .travelDataChanged,
            object: nil
        )
    }

    private func setupUI() {
        let verticalOffset: CGFloat = 20
        let chartSize: CGFloat = 250

        totalBudgetLabel.font = .boldSystemFont(ofSize: 18)
        totalBudgetLabel.textAlignment = .center
        totalBudgetLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(totalBudgetLabel)

        totalBudgetPieChartView.delegate = self
        totalBudgetPieChartView.legend.enabled = false
        totalBudgetPieChartView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(totalBudgetPieChartView)

        totalBudgetEmptyLabel.font = .systemFont(ofSize: 14)
        totalBudgetEmptyLabel.textAlignment = .center
        totalBudgetEmptyLabel.textColor = .gray
        totalBudgetEmptyLabel.text = "No budget has been set yet."
        totalBudgetEmptyLabel.isHidden = true
        totalBudgetEmptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(totalBudgetEmptyLabel)

        totalExpensesLabel.font = .boldSystemFont(ofSize: 18)
        totalExpensesLabel.textAlignment = .center
        totalExpensesLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(totalExpensesLabel)

        totalExpensesPieChartView.delegate = self
        totalExpensesPieChartView.legend.enabled = false
        totalExpensesPieChartView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(totalExpensesPieChartView)

        totalExpensesEmptyLabel.font = .systemFont(ofSize: 14)
        totalExpensesEmptyLabel.textAlignment = .center
        totalExpensesEmptyLabel.textColor = .gray
        totalExpensesEmptyLabel.text = "No expenses recorded yet."
        totalExpensesEmptyLabel.isHidden = true
        totalExpensesEmptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(totalExpensesEmptyLabel)

        NSLayoutConstraint.activate([
            totalBudgetLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: verticalOffset),
            totalBudgetLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            totalBudgetLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            totalBudgetPieChartView.topAnchor.constraint(equalTo: totalBudgetLabel.bottomAnchor, constant: 10),
            totalBudgetPieChartView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            totalBudgetPieChartView.widthAnchor.constraint(equalToConstant: chartSize),
            totalBudgetPieChartView.heightAnchor.constraint(equalTo: totalBudgetPieChartView.widthAnchor),

            totalBudgetEmptyLabel.centerXAnchor.constraint(equalTo: totalBudgetPieChartView.centerXAnchor),
            totalBudgetEmptyLabel.centerYAnchor.constraint(equalTo: totalBudgetPieChartView.centerYAnchor),

            totalExpensesLabel.topAnchor.constraint(equalTo: totalBudgetPieChartView.bottomAnchor, constant: 20),
            totalExpensesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            totalExpensesLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            totalExpensesPieChartView.topAnchor.constraint(equalTo: totalExpensesLabel.bottomAnchor, constant: 10),
            totalExpensesPieChartView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            totalExpensesPieChartView.widthAnchor.constraint(equalToConstant: chartSize),
            totalExpensesPieChartView.heightAnchor.constraint(equalTo: totalExpensesPieChartView.widthAnchor),

            totalExpensesEmptyLabel.centerXAnchor.constraint(equalTo: totalExpensesPieChartView.centerXAnchor),
            totalExpensesEmptyLabel.centerYAnchor.constraint(equalTo: totalExpensesPieChartView.centerYAnchor)
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

        setupViewWithTravelPlan()
    }

    private func setupViewWithTravelPlan() {
        guard let travelPlan = travelPlan else { return }
        updateLabels()
        updatePieCharts()
    }

    private func updateLabels() {
        let totalBudget = categories.reduce(0) { $0 + $1.budgetAmount }
        let totalExpenses = spendingItems.reduce(0) { $0 + $1.amount }
        let percentage = totalBudget > 0 ? (totalExpenses / totalBudget * 100) : 0 // Avoid division by zero

        totalBudgetLabel.text = "Total Budget: \(currencySymbol)  \(totalBudget)"
        totalExpensesLabel.text = "Total Expenses: \(currencySymbol)  \(totalExpenses) (\(String(format: "%.0f", percentage))%)"
    }

    private func updatePieCharts() {
            let totalBudget = categories.reduce(0) { $0 + $1.budgetAmount }
            let totalExpenses = spendingItems.reduce(0) { $0 + $1.amount }

            if totalBudget == 0 {
                totalBudgetPieChartView.isHidden = true
                totalBudgetEmptyLabel.isHidden = false
            } else {
                totalBudgetPieChartView.isHidden = false
                totalBudgetEmptyLabel.isHidden = true
                updateTotalBudgetPieChart()
            }

            if totalExpenses == 0 {
                totalExpensesPieChartView.isHidden = true
                totalExpensesEmptyLabel.isHidden = false
            } else {
                totalExpensesPieChartView.isHidden = false
                totalExpensesEmptyLabel.isHidden = true
                updateTotalExpensesPieChart()
            }
        }


    private func updateTotalBudgetPieChart() {
        let totalBudget = categories.reduce(0) { $0 + $1.budgetAmount }

        var entries: [PieChartDataEntry] = []
        for category in categories {
            let percentage = (category.budgetAmount / totalBudget) * 100
            let entry = PieChartDataEntry(
                value: category.budgetAmount,
                label: "\(category.name)\n (\(String(format: "%.0f", percentage))%)"
            )
            entries.append(entry)
        }

        let dataSet = PieChartDataSet(entries: entries, label: "")
        dataSet.colors = ChartColorTemplates.joyful()
        dataSet.sliceSpace = 2.0

        let data = PieChartData(dataSet: dataSet)
        data.setValueTextColor(.black)
        data.setValueFont(.systemFont(ofSize: 12, weight: .bold))

        totalBudgetPieChartView.data = data
        totalBudgetPieChartView.notifyDataSetChanged()
    }

    private func updateTotalExpensesPieChart() {
        let totalExpenses = spendingItems.reduce(0) { $0 + $1.amount }

        var entries: [PieChartDataEntry] = []
        for category in categories {
            let categoryExpenses = spendingItems
                .filter { $0.categoryId == category.id }
                .reduce(0) { $0 + $1.amount }
            let percentage = (categoryExpenses / totalExpenses) * 100
            let entry = PieChartDataEntry(
                value: categoryExpenses,
                label: "\(category.name)\n (\(String(format: "%.0f", percentage))%)"
            )
            entries.append(entry)
        }

        let dataSet = PieChartDataSet(entries: entries, label: "")
        dataSet.colors = ChartColorTemplates.vordiplom()
        dataSet.sliceSpace = 2.0

        let data = PieChartData(dataSet: dataSet)
        data.setValueTextColor(.black)
        data.setValueFont(.systemFont(ofSize: 12, weight: .bold))

        totalExpensesPieChartView.data = data
        totalExpensesPieChartView.notifyDataSetChanged()
    }
    
    @objc private func handleTravelDataChanged(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let travelId = userInfo["travelId"] as? String,
              travelPlan?.id == travelId else { return }

        guard let categoryIds = travelPlan?.categoryIds, !categoryIds.isEmpty else {
            print("No categories to fetch for travel plan \(travelId).")
            categories = []
            spendingItems = []
            updateLabels()
            updatePieCharts()
            return
        }

        SpendingFirebaseManager.shared.fetchCategoriesByIds(categoryIds: categoryIds) { [weak self] categories in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.categories = categories

                // Fetch spending items for the updated categories
                SpendingFirebaseManager.shared.fetchSpendingItemsByCategoryIds(categoryIds: categoryIds) { spendingItems in
                    DispatchQueue.main.async {
                        self.spendingItems = spendingItems
                        self.updateLabels()
                        self.updatePieCharts()
                    }
                }
            }
        }
    }
    
    
}
