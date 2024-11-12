//
//  SpendingView.swift
//  Packsync
//
//  Created by Xu Yang on 11/11/24.
//

import UIKit

class SpendingView: UIView {
    
    // MARK: - UI Elements
    let tabBar: UISegmentedControl
    let containerView: UIView

    // Initialize with custom segmented control items
    override init(frame: CGRect) {
        tabBar = UISegmentedControl(items: ["Overview", "Budget", "Expenses", "Split"])
        containerView = UIView()
        
        super.init(frame: frame)
        
        setupTabBar()
        setupContainerView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Functions
    
    private func setupTabBar() {
        // Set default selected segment
        tabBar.selectedSegmentIndex = 0
        
        // Customize appearance
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tabBar)
        
        NSLayoutConstraint.activate([
            tabBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tabBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func setupContainerView() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: tabBar.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
