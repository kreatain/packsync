//
//  SpendingViewController.swift
//  Packsync
//
//  Created by Xu Yang on 11/11/24.
//

import UIKit
import FirebaseAuth

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
    private var currentBalance: Balance?
    private var userIcons: [String: UIImage] = [:] // Dictionary to store user icons by user ID
    
    private lazy var overviewVC = OverviewViewController()
    private lazy var budgetVC = BudgetViewController()
    private lazy var expensesVC = ExpensesViewController()
    private lazy var splitVC = SplitViewController()
    
    private let travelTitleLabel = UILabel() // Label to show the travel plan's name on top of the tab bar
    private var listenerInitialized: Bool = false
    private var refreshInProgress = false
    private var refreshTask: DispatchWorkItem?
    
    
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
        
        showNoActivePlanNotice()
        
        // Add observer to listen for updates
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTravelData), name: .travelDataChanged, object: nil)
        
        // Listen for ActiveTravelPlan change
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleActiveTravelPlanChange),
            name: .activeTravelPlanChanged,
            object: nil
        )
        
        NotificationCenter.default.addObserver(self, selector: #selector(userDidLogout), name: .userDidLogout, object: nil)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        CentralizedFirebaseListener.shared.stopAllListeners()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("Title Label Frame:", travelTitleLabel.frame)
        print("Tab Bar Frame:", spendingView.tabBar.frame)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("[SpendingViewController] viewWillAppear triggered.")
        
        // Stop existing listeners and set up new ones
        CentralizedFirebaseListener.shared.stopAllListeners()
        listenerInitialized = false
        setupListeners()
        
        // Force refresh travel data
        refreshTravelData()
        loadTravelPlan()
    }
    
    
    private func setupListeners() {
        guard let travelID = travelID else {
            print("[SpendingViewController] setupListeners called but travelID is nil.")
            return
        }
        
        CentralizedFirebaseListener.shared.stopAllListeners()
        
        CentralizedFirebaseListener.shared.startListeningToAll(
            for: travelID,
            participantIds: travelPlan?.participantIds ?? [],
            travelUpdate: { [weak self] updatedTravel in
                guard let self = self, let updatedTravel = updatedTravel else { 
                    print("[SpendingViewController] travelUpdate listener invoked but updatedTravel is nil.")
                    return 
                }
                print("[SpendingViewController] travelUpdate listener invoked with travelTitle: \(updatedTravel.travelTitle).")
                self.travelPlan = updatedTravel
                self.updateUIWithTravelPlan(updatedTravel)
            },
            categoryUpdate: { [weak self] updatedCategories in
                guard let self = self else { return }
                self.categories = updatedCategories
                self.notifyChildControllers()
            },
            spendingItemsUpdate: { [weak self] updatedSpendingItems in
                guard let self = self else { return }
                self.spendingItems = updatedSpendingItems
                self.notifyChildControllers()
            },
            balancesUpdate: { [weak self] updatedBalances in
                guard let self = self else { return }
                print("[SpendingViewController] Active balance fetched and updated.")
                if let activeBalance = updatedBalances.first(where: { !$0.isSet }) {
                    self.currentBalance = activeBalance // Update the active balance
                    self.notifyChildControllers()
                }
            },
            participantsUpdate: { [weak self] updatedParticipants in
                guard let self = self else { return }
                self.participants = updatedParticipants
                self.notifyChildControllers()
            }
        )
    }
    
    private func notifyChildControllers() {
        guard let travelPlan = travelPlan else {
            print("[SpendingViewController] Error: travelPlan is nil. Cannot notify child controllers.")
            return
        }
        
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
            spendingItems: spendingItems,
            participants: participants,
            currencySymbol: travelPlan.currency ,
            userIcons: userIcons
        )
        expensesVC.setTravelPlan(
            travelPlan,
            categories: categories,
            spendingItems: spendingItems,
            participants: participants,
            currencySymbol: travelPlan.currency ,
            userIcons: userIcons
        )
        splitVC.setTravelPlan(
            travelPlan: travelPlan,
            participants: participants,
            currentBalance: currentBalance,
            unsettledSpendingItems: spendingItems.filter { !$0.isSettled },
            settledSpendingItems: spendingItems.filter { $0.isSettled },
            categories: categories,
            userIcons: userIcons,
            currencySymbol: travelPlan.currency
        )
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
        startLoading()

        // Track the source of travelID
        if let explicitlySetTravelID = self.travelID {
            print("[SpendingViewController] Using explicitly set travelID: \(explicitlySetTravelID)")
        } else if let activeTravelPlan = TravelPlanManager.shared.activeTravelPlan {
            print("[SpendingViewController] Using active travel plan ID: \(activeTravelPlan.id), Title: \(activeTravelPlan.travelTitle)")
        } else {
            print("[SpendingViewController] No travelID or active travel plan available.")
        }

        // Fetch travel ID
        let travelIDToFetch = self.travelID ?? TravelPlanManager.shared.activeTravelPlan?.id

        // Log the outcome
        if let travelID = travelIDToFetch {
            print("[SpendingViewController] Fetching travel plan with ID: \(travelID)")
            SpendingFirebaseManager.shared.fetchTravel(for: travelID) { [weak self] travelPlan in
                guard let self = self else { return }
                if let travelPlan = travelPlan {
                    print("[SpendingViewController] Travel plan fetched successfully: ID: \(travelPlan.id), Title: \(travelPlan.travelTitle)")
                    self.populateTravelPlanData(for: travelPlan.id) {
                        DispatchQueue.main.async {
                            self.stopLoading()
                        }
                    }
                } else {
                    print("[SpendingViewController] No travel plan found for ID: \(travelID)")
                    DispatchQueue.main.async {
                        self.stopLoading()
                        self.showNoActivePlanNotice()
                    }
                }
            }
        } else {
            print("[SpendingViewController] No travel ID or active travel plan available to fetch.")
            DispatchQueue.main.async {
                self.stopLoading()
                self.showNoActivePlanNotice()
            }
        }
    }
    
    @objc private func handleActiveTravelPlanChange(notification: Notification) {
        print("Active Travel changed, start loading new...")
        self.travelID = nil
        loadTravelPlan()

    }
    
    @objc private func userDidLogout() {
        DispatchQueue.main.async {
            print("[SpendingViewController] User logged out. Resetting UI.")
            
            self.categories.removeAll()
            self.spendingItems.removeAll()
            self.participants.removeAll()
            
            self.spendingView.isHidden = true
            self.noActivePlanLabel.isHidden = true
            self.travelTitleLabel.isHidden = true
            self.loadingIndicator.stopAnimating()
            self.listenerInitialized = false

            // Reset the travelPlan and travelID to nil
            self.travelPlan = nil
            self.travelID = nil

            // Display the login prompt if required
            self.noActivePlanLabel.text = "Please create an account or log in to view Spending details."
            self.noActivePlanLabel.isHidden = false
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
    
    private func populateTravelPlanData(for travelPlanId: String, completion: @escaping () -> Void) {
        print("populateTravelPlanData called for travelPlan ID: \(travelPlanId)")
        
        travelID = travelPlanId
        setupListeners() // Setup listeners after travelID is updated
        
        let dispatchGroup = DispatchGroup()
        var fetchedTravelPlan: Travel?
        var fetchedCategories: [Category] = []
        var fetchedSpendingItems: [SpendingItem] = []
        var fetchedBalances: [Balance] = []
        var fetchedParticipants: [User] = []
        var fetchedActiveBalance: Balance?
        
        // Fetch Travel Plan
        dispatchGroup.enter()
        SpendingFirebaseManager.shared.fetchTravel(for: travelPlanId) { travelPlan in
            fetchedTravelPlan = travelPlan
            dispatchGroup.leave()
        }
        
        // Wait for travel plan fetch
        dispatchGroup.notify(queue: .global()) {
            guard let travelPlan = fetchedTravelPlan else {
                print("Error: No travel plan found.")
                DispatchQueue.main.async {
                    self.showNoActivePlanNotice()
                    completion()
                }
                return
            }
            
            // Fetch Categories
            dispatchGroup.enter()
            SpendingFirebaseManager.shared.fetchCategoriesByIds(categoryIds: travelPlan.categoryIds) { categories in
                fetchedCategories = categories
                dispatchGroup.leave()
            }
            
            // Fetch Spending Items
            dispatchGroup.enter()
            SpendingFirebaseManager.shared.fetchSpendingItemsByCategoryIds(categoryIds: travelPlan.categoryIds) { spendingItems in
                fetchedSpendingItems = spendingItems
                dispatchGroup.leave()
            }
            
            // Fetch Active Balance
                dispatchGroup.enter()
                SpendingFirebaseManager.shared.ensureActiveBalance(for: travelPlanId) { activeBalance in
                    fetchedActiveBalance = activeBalance
                    dispatchGroup.leave()
                }
            
            // Fetch Participants and Icons
            dispatchGroup.enter()
            self.fetchParticipantsAndIcons(for: travelPlan.participantIds) { participants in
                fetchedParticipants = participants
                dispatchGroup.leave()
            }
            
            // Notify when all fetches are done
            dispatchGroup.notify(queue: .main) {
                self.travelPlan = travelPlan
                self.categories = fetchedCategories
                self.spendingItems = fetchedSpendingItems
                self.currentBalance = fetchedActiveBalance
                self.participants = fetchedParticipants
                
                print("[SpendingViewController] Finished populating data. Updating child views.")
                self.updateUIWithTravelPlan(travelPlan)
                completion()
            }
        }
    }
    
    private func updateUIWithTravelPlan(_ travelPlan: Travel) {
        
        print("[SpendingViewController] Updating UI for travel plan: \(travelPlan.travelTitle).")
        print("[SpendingViewController] Current state: Categories: \(categories.count), Spending Items: \(spendingItems.count), Participants: \(participants.count).")
        
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
            overviewVC.view.setNeedsLayout()
            overviewVC.view.layoutIfNeeded()
            
            budgetVC.setTravelPlan(
                travelPlan,
                categories: categories,
                spendingItems: spendingItems, // Add spending items here
                participants: participants,
                currencySymbol: travelPlan.currency,
                userIcons: userIcons
            )
            budgetVC.view.setNeedsLayout()
            budgetVC.view.layoutIfNeeded()
            
            expensesVC.setTravelPlan(
                travelPlan,
                categories: categories,
                spendingItems: spendingItems,
                participants: participants,
                currencySymbol: travelPlan.currency,
                userIcons: userIcons
            )
            expensesVC.view.setNeedsLayout()
            expensesVC.view.layoutIfNeeded()
            
            
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
            splitVC.view.setNeedsLayout()
            splitVC.view.layoutIfNeeded()
            
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

        if Auth.auth().currentUser == nil {
            noActivePlanLabel.text = "Please create an account or log in to view Spending details."
        } else {
            noActivePlanLabel.text = "Please select an active travel plan to view Spending details."
        }
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
        refreshTask?.cancel() // Cancel the previous task
        refreshTask = nil
        let newTask = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.performTravelDataRefresh()
        }
        refreshTask = newTask
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: newTask) // Debounce
    }
    
    private func performTravelDataRefresh() {
        guard !refreshInProgress else {
            print("[SpendingViewController] refreshTravelData skipped: already in progress.")
            return
        }
        
        refreshInProgress = true
        print("[SpendingViewController] refreshTravelData called.")
        
        if let travelID = travelID {
            print("[SpendingViewController] Refreshing travel data for ID: \(travelID).")
            populateTravelPlanData(for: travelID) {
                self.refreshInProgress = false
                print("[SpendingViewController] refreshTravelData completed for travel ID: \(travelID).")
            }
        } else if let activePlan = TravelPlanManager.shared.activeTravelPlan {
            print("[SpendingViewController] Refreshing active travel plan with ID: \(activePlan.id).")
            populateTravelPlanData(for: activePlan.id) {
                self.refreshInProgress = false
                print("[SpendingViewController] refreshTravelData completed for active travel plan ID: \(activePlan.id).")
            }
        } else {
            print("[SpendingViewController] No travel ID or active plan available for refresh.")
            showNoActivePlanNotice()
            refreshInProgress = false
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
