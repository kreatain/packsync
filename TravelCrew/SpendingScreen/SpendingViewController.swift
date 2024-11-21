//
//  SpendingViewController.swift
//  Packsync
//
//  Created by Xu Yang on 11/11/24.
//

import UIKit

class SpendingViewController: UIViewController {
    private let spendingView = SpendingView() // Using SpendingView for layout
    private let loadingIndicator = UIActivityIndicatorView(style: .large) // Add loading indicator
    private var isLoading = false
    private var travelID: String? // Optional travelID parameter for specific travel plan
    private var travelPlan: Travel?
    private let noActivePlanLabel = UILabel() // Label to prompt user to set active plan
    private var currentTabIndex: Int = 0
    
    private var categories: [Category] = []
    private var spendingItems: [SpendingItem] = []
    private var participants: [User] = []
    private var balances: [Balance] = []
    private var userIcons: [String: UIImage] = [:] // Dictionary to store user icons by user ID
    
    private lazy var overviewVC = OverviewViewController()
    private lazy var budgetVC = BudgetViewController()
    private lazy var expensesVC = ExpensesViewController()
    private lazy var splitVC = SplitViewController()
    
    private let travelTitleLabel = UILabel() // Label to show the travel plan's name on top of the tab bar
    
    
    // Initializer to accept travelID parameter
    init(travelID: String? = nil) {
        self.travelID = travelID
        super.init(nibName: nil, bundle: nil)
        print("[SpendingViewController] Initialized with travelID: \(String(describing: travelID))")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set initial visibility
        spendingView.isHidden = true
        noActivePlanLabel.isHidden = true
        
        setupSpendingView()
        setupTravelTitleLabel()
        setupNoActivePlanLabel()
        setupLoadingIndicator()
        setupTabBarAction()
        loadTravelPlan()
        
        setupListeners()
        
        // Listen for active travel plan changes
        NotificationCenter.default.addObserver(self, selector: #selector(loadTravelPlan), name: .activeTravelPlanChanged, object: nil)
        // Add observer to listen for updates
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTravelData), name: .travelDataChanged, object: nil)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            SpendingFirebaseManager.shared.stopAllListeners()
        }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("Title Label Frame:", travelTitleLabel.frame)
        print("Tab Bar Frame:", spendingView.tabBar.frame)
    }
    
    private func setupListeners() {
            guard let travelID = travelID else { return }

            SpendingFirebaseManager.shared.startListeningToTravelPlan(for: travelID) { [weak self] updatedTravel in
                guard let self = self, let updatedTravel = updatedTravel else { return }
                self.travelPlan = updatedTravel
                self.updateUIWithTravelPlan(updatedTravel)
            }

        }
    
    // MARK: - Setup Loading Indicator
    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func startLoading() {
        isLoading = true
        spendingView.isHidden = true
        noActivePlanLabel.isHidden = true
        loadingIndicator.startAnimating()
    }
    
    private func stopLoading() {
        isLoading = false
        loadingIndicator.stopAnimating()
        spendingView.isHidden = false
    }
    
    private func setupSpendingView() {
        view.addSubview(spendingView)
        spendingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spendingView.topAnchor.constraint(equalTo: view.topAnchor),
            spendingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            spendingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            spendingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTabBarAction() {
        spendingView.tabBar.addTarget(self, action: #selector(tabChanged(_:)), for: .valueChanged)
    }
    
    private func setupNoActivePlanLabel() {
        noActivePlanLabel.text = "Please select an active travel plan to view Spending details."
        noActivePlanLabel.textAlignment = .center
        noActivePlanLabel.numberOfLines = 0
        noActivePlanLabel.textColor = .gray
        noActivePlanLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noActivePlanLabel)
        
        NSLayoutConstraint.activate([
            noActivePlanLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noActivePlanLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noActivePlanLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            noActivePlanLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupTravelTitleLabel() {
        travelTitleLabel.font = .boldSystemFont(ofSize: 18)
        travelTitleLabel.textAlignment = .center
        travelTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        spendingView.addSubview(travelTitleLabel)
        
        let topAnchorConstraint: NSLayoutConstraint
        if let _ = navigationController, travelID != nil {
            // In a navigation stack with back button
            topAnchorConstraint = travelTitleLabel.topAnchor.constraint(equalTo: spendingView.safeAreaLayoutGuide.topAnchor, constant: 0)
        } else {
            // No navigation stack, align directly to the top
            topAnchorConstraint = travelTitleLabel.topAnchor.constraint(equalTo: spendingView.topAnchor, constant: 70)
        }
        
        NSLayoutConstraint.activate([
            topAnchorConstraint,
            travelTitleLabel.leadingAnchor.constraint(equalTo: spendingView.leadingAnchor),
            travelTitleLabel.trailingAnchor.constraint(equalTo: spendingView.trailingAnchor)
        ])
    }
    
    // MARK: - Load Travel Plan
    @objc private func loadTravelPlan() {
        print("[SpendingViewController] loadTravelPlan called.")
        
        // Start loading animation
        startLoading()
        
        if let travelID = travelID {
            print("[SpendingViewController] Fetching travel plan with ID: \(travelID).")
            SpendingFirebaseManager.shared.fetchTravel(for: travelID) { [weak self] travelPlan in
                guard let self = self else { return }
                
                if let travelPlan = travelPlan {
                    print("[SpendingViewController] Travel plan fetched successfully.")
                    self.populateTravelPlanData(for: travelPlan.id)
                } else {
                    print("[SpendingViewController] No travel plan found for ID: \(travelID).")
                    DispatchQueue.main.async {
                        self.stopLoading()
                        self.showNoActivePlanNotice()
                    }
                }
            }
        } else if let activePlan = TravelPlanManager.shared.activeTravelPlan {
            print("[SpendingViewController] Using active travel plan with ID: \(activePlan.id).")
            populateTravelPlanData(for: activePlan.id)
        } else {
            print("[SpendingViewController] No travel ID or active travel plan available.")
            DispatchQueue.main.async {
                self.stopLoading()
                self.showNoActivePlanNotice()
            }
        }
    }
    
    private func fetchParticipantsAndIcons(for participantIds: [String], completion: @escaping ([User]) -> Void) {
        SpendingFirebaseManager.shared.fetchUsersByIds(userIds: participantIds) { [weak self] fetchedParticipants in
            guard let self = self else { return }
            
            let dispatchGroup = DispatchGroup()
            var icons: [String: UIImage] = [:]
            
            for user in fetchedParticipants {
                guard let profilePicURL = user.profilePicURL, let url = URL(string: profilePicURL) else {
                    icons[user.id] = UIImage(systemName: "person.circle") // Default icon
                    continue
                }
                
                dispatchGroup.enter()
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    defer { dispatchGroup.leave() }
                    if let data = data, let image = UIImage(data: data) {
                        icons[user.id] = image
                    } else {
                        icons[user.id] = UIImage(systemName: "person.circle") // Default icon
                    }
                }.resume()
            }
            
            dispatchGroup.notify(queue: .main) {
                self.userIcons = icons // Set user icons globally
                completion(fetchedParticipants)
            }
        }
    }
    
    private func populateTravelPlanData(for travelPlanId: String) {
        print("populateTravelPlanData called for travelPlan ID: \(travelPlanId)")
        
        var localTravelPlan: Travel?
        var categories: [Category] = []
        var spendingItems: [SpendingItem] = []
        var balances: [Balance] = []
        var participants: [User] = []
        
        let dispatchGroup = DispatchGroup()
        
        // Step 1: Fetch the latest travel plan from Firestore
        dispatchGroup.enter()
        SpendingFirebaseManager.shared.fetchTravel(for: travelPlanId) { fetchedTravelPlan in
            guard let fetchedTravelPlan = fetchedTravelPlan else {
                print("Error: Failed to fetch the travel plan from Firestore.")
                dispatchGroup.leave()
                return
            }
            
            localTravelPlan = fetchedTravelPlan
            print("Fetched latest travel plan:")
            print("""
            - ID: \(fetchedTravelPlan.id)
            - Title: \(fetchedTravelPlan.travelTitle)
            - Category IDs: \(fetchedTravelPlan.categoryIds)
            - Expense IDs: \(fetchedTravelPlan.expenseIds)
            """)
            dispatchGroup.leave()
        }
        
        // Wait for travel plan to be fetched before proceeding
        dispatchGroup.notify(queue: .global()) {
            guard let travelPlan = localTravelPlan else {
                print("Error: Local travel plan is nil. Aborting data fetch.")
                return
            }
            
            // Step 2: Fetch categories using updated category IDs
            dispatchGroup.enter()
            print("Fetching categories for travel plan ID: \(travelPlan.id) with updated category IDs: \(travelPlan.categoryIds)")
            SpendingFirebaseManager.shared.fetchCategoriesByIds(categoryIds: travelPlan.categoryIds) { fetchedCategories in
                categories = fetchedCategories
                print("Fetched \(fetchedCategories.count) categories.")
                dispatchGroup.leave()
            }
            
            // Step 3: Fetch spending items using updated category IDs
            dispatchGroup.enter()
            print("Fetching spending items for updated category IDs: \(travelPlan.categoryIds)")
            SpendingFirebaseManager.shared.fetchSpendingItemsByCategoryIds(categoryIds: travelPlan.categoryIds) { fetchedSpendingItems in
                spendingItems = fetchedSpendingItems
                print("Fetched \(fetchedSpendingItems.count) spending items.")
                dispatchGroup.leave()
            }
            
            // Step 4: Fetch balances using updated balance IDs
            dispatchGroup.enter()
            print("Fetching balances for travel plan ID: \(travelPlan.id) with updated balance IDs: \(travelPlan.balanceIds)")
            SpendingFirebaseManager.shared.fetchBalances(for: travelPlan.id) { fetchedBalances in
                balances = fetchedBalances
                print("Fetched \(fetchedBalances.count) balances for travel plan ID \(travelPlan.id).")
                dispatchGroup.leave()
            }
            
            // Step 5: Fetch participants and their icons using updated participant IDs
            dispatchGroup.notify(queue: .main) {
                dispatchGroup.enter()
                self.fetchParticipantsAndIcons(for: travelPlan.participantIds) { fetchedParticipants in
                    participants = fetchedParticipants
                    dispatchGroup.leave()
                }
                
                dispatchGroup.notify(queue: .main) {
                    self.travelPlan = travelPlan
                    self.categories = categories
                    self.spendingItems = spendingItems
                    self.balances = balances
                    self.participants = participants
                    self.stopLoading()
                    
                    print("[SpendingViewController] Finished populating data. Updating child views.")
                    self.updateUIWithTravelPlan(travelPlan)
                }
            }
        }
    }
    
    private func updateUIWithTravelPlan(_ travelPlan: Travel) {
        print("[SpendingViewController] Updating UI for travel plan: \(travelPlan.travelTitle).")
        print("[SpendingViewController] Categories: \(categories.count), Spending Items: \(spendingItems.count), Participants: \(participants.count).")
        
        travelTitleLabel.text = travelPlan.travelTitle
        spendingView.isHidden = false
        noActivePlanLabel.isHidden = true
        
        // Ensure we get the active balance or create a new one if none exists
        SpendingFirebaseManager.shared.ensureActiveBalance(for: travelPlan.id) { [weak self] activeBalance in
            guard let self = self else { return }
            
            let activeBalance = activeBalance ?? Balance(travelId: travelPlan.id)
            
            // Filter spending items for unsettled/settled items
            let unsettledSpendingItems = self.spendingItems.filter { !$0.isSettled }
            let settledSpendingItems = self.spendingItems.filter { $0.isSettled }
            
            // Pass resolved data to child view controllers
            overviewVC.setTravelPlan(
                travelPlan,
                categories: categories,
                spendingItems: spendingItems,
                participants: participants,
                currencySymbol: travelPlan.currency
            )
            budgetVC.setTravelPlan(
                travelPlan,
                categories: categories,
                spendingItems: spendingItems, // Add spending items here
                participants: participants,
                currencySymbol: travelPlan.currency,
                userIcons: userIcons
            )
            expensesVC.setTravelPlan(
                travelPlan,
                categories: categories,
                spendingItems: spendingItems,
                participants: participants,
                currencySymbol: travelPlan.currency,
                userIcons: userIcons
            )
            splitVC.setTravelPlan(
                travelPlan: travelPlan,
                participants: self.participants,
                currentBalance: activeBalance, 
                unsettledSpendingItems: unsettledSpendingItems,
                settledSpendingItems: settledSpendingItems,
                categories: categories,
                userIcons: userIcons,
                currencySymbol: travelPlan.currency
            )
            
            // Restore the active tab
            switch currentTabIndex {
            case 0:
                switchToViewController(overviewVC)
            case 1:
                switchToViewController(budgetVC)
            case 2:
                switchToViewController(expensesVC)
            case 3:
                switchToViewController(splitVC)
            default:
                switchToViewController(overviewVC)
            }
        }
    }
    
    
    private func showNoActivePlanNotice() {
        spendingView.isHidden = true
        noActivePlanLabel.isHidden = false
    }
    
    @objc private func tabChanged(_ sender: UISegmentedControl) {
        currentTabIndex = sender.selectedSegmentIndex
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
        spendingView.addSubview(viewController.view)
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: spendingView.tabBar.bottomAnchor, constant: 10),
            viewController.view.leadingAnchor.constraint(equalTo: spendingView.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: spendingView.trailingAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: spendingView.bottomAnchor)
        ])
        
        viewController.didMove(toParent: self)
    }
    
    private func removeCurrentChildViewController() {
        for child in children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }
    
    @objc private func refreshTravelData() {
        print("[SpendingViewController] refreshTravelData called.")
        
        if let travelID = travelID {
            // Case 1: Refresh using the provided travel ID
            print("[SpendingViewController] Refreshing travel data for ID: \(travelID).")
            self.populateTravelPlanData(for: travelID)
        } else if let activePlan = TravelPlanManager.shared.activeTravelPlan {
            // Case 2: Refresh using the active travel plan's ID
            print("[SpendingViewController] Refreshing active travel plan with ID: \(activePlan.id).")
            self.populateTravelPlanData(for: activePlan.id)
        } else {
            // Case 3: No travel ID or active plan available
            print("[SpendingViewController] No travel ID or active plan available for refresh. Showing no active plan notice.")
            showNoActivePlanNotice()
        }
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Method to dynamically set travel title
    func setTravelTitle(_ title: String) {
        travelTitleLabel.text = title
    }
}
