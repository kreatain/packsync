//
//  SpendingViewController.swift
//  Packsync
//
//  Created by Xu Yang on 11/11/24.
//

import UIKit

class SpendingViewController: UIViewController {
    private let spendingView = SpendingView() // Using SpendingView for layout
    private var travelID: String? // Optional travelID parameter for specific travel plan

    private lazy var overviewVC = OverviewViewController()
    private lazy var budgetVC = BudgetViewController()
    private lazy var expensesVC = ExpensesViewController()
    private lazy var splitVC = SplitViewController()

    // Initializer to accept travelID parameter
    init(travelID: String? = nil) {
        self.travelID = travelID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(spendingView)
        spendingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spendingView.topAnchor.constraint(equalTo: view.topAnchor),
            spendingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            spendingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            spendingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        setupTabBarAction()
        loadTravelPlan()
        
        // Listen for active travel plan changes
        NotificationCenter.default.addObserver(self, selector: #selector(loadTravelPlan), name: .activeTravelPlanChanged, object: nil)
    }
    
    private func setupTabBarAction() {
        spendingView.tabBar.addTarget(self, action: #selector(tabChanged(_:)), for: .valueChanged)
    }
    
    // MARK: - Load Travel Plan
    /// Loads the travel plan based on the provided `travelID` or active plan.
    @objc private func loadTravelPlan() {
        if let travelID = travelID {
            // Fetch the specific travel plan by ID
            fetchTravelPlanByID(travelID) { [weak self] travelPlan in
                guard let self = self, let travelPlan = travelPlan else {
                    self?.showNoActivePlanNotice()
                    return
                }
                self.spendingView.isHidden = false
                self.renderContentForTravelPlan(travelPlan)
            }
        } else if let activePlan = TravelPlanManager.shared.activeTravelPlan {
            // Use the active travel plan if no travelID is provided
            spendingView.isHidden = false
            renderContentForTravelPlan(activePlan)
        } else {
            // Show notice if no active plan and no travelID provided
            spendingView.isHidden = true
            showNoActivePlanNotice()
        }
    }
    
    private func fetchTravelPlanByID(_ travelID: String, completion: @escaping (Travel?) -> Void) {
        // Placeholder for database or API call to fetch the Travel by ID
        // For testing, you can simulate a travel plan
        let mockPlan = Travel(creatorEmail: "test@example.com", travelTitle: "Mock Trip", travelStartDate: "2024-01-01", travelEndDate: "2024-01-10", countryAndCity: "Mock City")
        completion(mockPlan) // Simulate fetching a travel plan with this ID
    }
    
    private func renderContentForTravelPlan(_ travelPlan: Travel) {
        // Update UI based on the provided or active travel plan
        add(asChildViewController: overviewVC) // Default tab
        print("Rendering content for travel plan: \(travelPlan.travelTitle)")
    }
    
    private func showNoActivePlanNotice() {
        let alert = UIAlertController(title: "No Active Plan", message: "Please select an active travel plan to view spending details.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    @objc private func tabChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            switchToViewController(overviewVC)
        case 1:
            switchToViewController(budgetVC)
        case 2:
            switchToViewController(expensesVC)
        case 3:
            switchToViewController(splitVC)
        default:
            break
        }
    }
    
    private func switchToViewController(_ viewController: UIViewController) {
        removeCurrentChildViewController()
        add(asChildViewController: viewController)
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        addChild(viewController)
        spendingView.containerView.addSubview(viewController.view)
        viewController.view.frame = spendingView.containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParent: self)
    }
    
    private func removeCurrentChildViewController() {
        for child in children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
