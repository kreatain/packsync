//
//  SplitViewController.swift
//  Packsync
//
//  Created by Xu Yang on 11/18/24.
//

import UIKit

class SplitViewController: UIViewController {
    
    // Properties
    private let tabBar = UISegmentedControl(items: ["Current Balance", "Settled Balances"])
    private let currentBalanceVC = CurrentBalanceViewController()
    private let settledBalancesVC = SettledBalancesViewController()
    private var travelPlan: Travel?
    private var participants: [User] = []
    private var currentBalance: Balance?
    private var settledBalances: [Balance] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Split Expenses"
        view.backgroundColor = .white
        
        setupTabBar()
        setupChildViewControllers()
        displayCurrentBalance()
    }
    
    // MARK: - Setup Tab Bar
    private func setupTabBar() {
        tabBar.selectedSegmentIndex = 0
        tabBar.addTarget(self, action: #selector(tabChanged(_:)), for: .valueChanged)
        view.addSubview(tabBar)
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tabBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - Setup Child View Controllers
    private func setupChildViewControllers() {
        add(asChildViewController: currentBalanceVC)
        add(asChildViewController: settledBalancesVC)
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: tabBar.bottomAnchor, constant: 8),
            viewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        viewController.didMove(toParent: self)
        viewController.view.isHidden = true
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
    
    // MARK: - Tab Switching
    @objc private func tabChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            displayCurrentBalance()
        } else {
            displaySettledBalances()
        }
    }
    
    private func displayCurrentBalance() {
        currentBalanceVC.view.isHidden = false
        settledBalancesVC.view.isHidden = true
    }
    
    private func displaySettledBalances() {
        currentBalanceVC.view.isHidden = true
        settledBalancesVC.view.isHidden = false
    }
    
    // MARK: - Set Travel Plan
    func setTravelPlan(
        travelPlan: Travel,
        participants: [User],
        currentBalance: Balance,
        settledBalances: [Balance]
    ) {
        self.travelPlan = travelPlan
        self.participants = participants
        self.currentBalance = currentBalance
        self.settledBalances = settledBalances
        
        currentBalanceVC.setBalanceData(balance: currentBalance, participants: participants)
        settledBalancesVC.setBalances(settledBalances, participants: participants)
    }
}
