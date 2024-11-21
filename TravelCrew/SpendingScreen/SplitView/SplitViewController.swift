//
//  SplitViewController.swift
//  Packsync
//

import UIKit

class SplitViewController: UIViewController {
    // MARK: - Properties
    private let tabBar = UISegmentedControl(items: ["Current Balance", "Settled Expenses"])
    private var currentBalanceVC: CurrentBalanceViewController!
    private var settledExpensesVC: SettledExpensesViewController!
    
    var travelPlan: Travel?
    var participants: [User] = []
    var currentBalance: Balance?
    var currencySymbol: String = "$"
    var unsettledSpendingItems: [SpendingItem] = []
    var settledSpendingItems: [SpendingItem] = []
    var categories: [Category] = [] // Store categories
    var userIcons: [String: UIImage] = [:] // Store user icons
    
    
    
    private let containerView = UIView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Split Expenses"
        setupUI()
        initializeChildViewControllers()
        tabBar.selectedSegmentIndex = 0
        displayCurrentBalanceTab()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(tabBar)
        
        tabBar.selectedSegmentIndex = 0
        tabBar.addTarget(self, action: #selector(tabChanged(_:)), for: .valueChanged)
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        
        // Add container view for child controllers
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tabBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            containerView.topAnchor.constraint(equalTo: tabBar.bottomAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func setTravelPlan(
        travelPlan: Travel,
        participants: [User],
        currentBalance: Balance?,
        unsettledSpendingItems: [SpendingItem],
        settledSpendingItems: [SpendingItem],
        categories: [Category], // Pass categories
        userIcons: [String: UIImage], // Pass user icons
        currencySymbol: String // Pass currency symbol
    ) {
        // Ensure child view controllers are initialized
        if currentBalanceVC == nil || settledExpensesVC == nil {
            initializeChildViewControllers()
        }
        
        // Update properties
        self.travelPlan = travelPlan
        self.participants = participants
        self.currentBalance = currentBalance
        self.unsettledSpendingItems = unsettledSpendingItems
        self.settledSpendingItems = settledSpendingItems
        self.currencySymbol = currencySymbol
        self.categories = categories
        self.userIcons = userIcons
        
        // Update child view controllers with new data
        currentBalanceVC.configure(
            travelPlan: travelPlan,
            participants: participants,
            currentBalance: currentBalance,
            unsettledSpendingItems: unsettledSpendingItems,
            settledSpendingItems: settledSpendingItems,
            userIcons: userIcons,
            currencySymbol: currencySymbol
        )
        settledExpensesVC.configure(
            settledSpendingItems: settledSpendingItems,
            unsettledSpendingItems: unsettledSpendingItems, // Pass unsettled spending items
            categories: categories,
            participants: participants,
            currencySymbol: currencySymbol,
            userIcons: userIcons,
            travelId: travelPlan.id 
        )
        
        // Reload the currently active tab's view
        if tabBar.selectedSegmentIndex == 0 {
            displayCurrentBalanceTab()
        } else {
            displaySettledExpensesTab()
        }
    }
    
    private func initializeChildViewControllers() {
        currentBalanceVC = CurrentBalanceViewController()
        settledExpensesVC = SettledExpensesViewController()
        
        // Pass data to child view controllers
        currentBalanceVC.configure(
            travelPlan: travelPlan,
            participants: participants,
            currentBalance: currentBalance,
            unsettledSpendingItems: unsettledSpendingItems,
            settledSpendingItems: settledSpendingItems, 
            userIcons: userIcons,
            currencySymbol: currencySymbol
        )
        settledExpensesVC.configure(
            settledSpendingItems: settledSpendingItems,
            unsettledSpendingItems: unsettledSpendingItems, // Pass unsettled spending items
            categories: categories,
            participants: participants,
            currencySymbol: currencySymbol,
            userIcons: userIcons,
            travelId: travelPlan?.id ?? ""
        )
    }
    
    // MARK: - Tab Switching
    @objc private func tabChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            displayCurrentBalanceTab()
        } else {
            displaySettledExpensesTab()
        }
    }
    
    private func displayCurrentBalanceTab() {
        // Remove any existing child view controllers
        settledExpensesVC?.willMove(toParent: nil)
        settledExpensesVC?.view.removeFromSuperview()
        settledExpensesVC?.removeFromParent()
        
        // Add current balance child view controller
        addChild(currentBalanceVC)
        containerView.addSubview(currentBalanceVC.view) // Add to containerView
        currentBalanceVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            currentBalanceVC.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            currentBalanceVC.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            currentBalanceVC.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            currentBalanceVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        currentBalanceVC.didMove(toParent: self)
    }
    
    private func displaySettledExpensesTab() {
        // Remove any existing child view controllers
        currentBalanceVC?.willMove(toParent: nil)
        currentBalanceVC?.view.removeFromSuperview()
        currentBalanceVC?.removeFromParent()
        
        // Add settled expenses child view controller
        addChild(settledExpensesVC)
        containerView.addSubview(settledExpensesVC.view) // Add to containerView
        settledExpensesVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            settledExpensesVC.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            settledExpensesVC.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            settledExpensesVC.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            settledExpensesVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        settledExpensesVC.didMove(toParent: self)
    }
}
