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
    private let noActivePlanLabel = UILabel() // Label to prompt user to set active plan

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
        
        setupNoActivePlanLabel()
        setupTabBarAction()
        loadTravelPlan()
        
        // Listen for active travel plan changes
        NotificationCenter.default.addObserver(self, selector: #selector(loadTravelPlan), name: .activeTravelPlanChanged, object: nil)
    }
    
    private func setupTabBarAction() {
        spendingView.tabBar.addTarget(self, action: #selector(tabChanged(_:)), for: .valueChanged)
    }
    
    private func setupNoActivePlanLabel() {
        noActivePlanLabel.text = "Please select an active travel plan to view spending details."
        noActivePlanLabel.textAlignment = .center
        noActivePlanLabel.numberOfLines = 0
        noActivePlanLabel.textColor = .gray
        noActivePlanLabel.isHidden = true // Initially hidden
        noActivePlanLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noActivePlanLabel)
        
        NSLayoutConstraint.activate([
            noActivePlanLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noActivePlanLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noActivePlanLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            noActivePlanLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
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
                self.noActivePlanLabel.isHidden = true
                self.renderContentForTravelPlan(travelPlan)
            }
        } else if let activePlan = TravelPlanManager.shared.activeTravelPlan {
            // Use the active travel plan if no travelID is provided
            spendingView.isHidden = false
            noActivePlanLabel.isHidden = true
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
        let mockPlan = Travel(
            id: travelID,
            creatorId: "mockCreatorId",
            travelTitle: "Mock Trip",
            travelStartDate: "2024-01-01",
            travelEndDate: "2024-01-10",
            countryAndCity: "Mock City",
            categoryIds: ["category1", "category2"],
            expenseIds: ["expense1", "expense2"],
            participantIds: ["user1", "user2"]
        )
        completion(mockPlan) // Simulate fetching a travel plan with this ID
    }
    private func renderContentForTravelPlan(_ travelPlan: Travel) {
        // Update UI based on the provided or active travel plan
        add(asChildViewController: overviewVC) // Default tab
        print("Rendering content for travel plan: \(travelPlan.travelTitle)")
    }
    
    private func showNoActivePlanNotice() {
        // Display the persistent notice for setting an active travel plan
        noActivePlanLabel.isHidden = false
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
