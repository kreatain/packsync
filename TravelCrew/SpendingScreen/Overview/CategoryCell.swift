//
//  CategoryCell.swift
//  Packsync
//
//  Created by Xu Yang on 11/11/24.
//

import UIKit

class CategoryCell: UITableViewCell {
    
    private let emojiLabel = UILabel()
    private let categoryLabel = UILabel()
    private let spendingLabel = UILabel()
    private let progressBar = UIProgressView(progressViewStyle: .default)
    private var currentCategoryId: String?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        emojiLabel.font = .systemFont(ofSize: 24)
        categoryLabel.font = .systemFont(ofSize: 16)
        spendingLabel.font = .systemFont(ofSize: 14)
        
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        spendingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(emojiLabel)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(spendingLabel)
        contentView.addSubview(progressBar)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            categoryLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 8),
            categoryLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            
            spendingLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 8),
            spendingLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 4),
            
            progressBar.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            progressBar.topAnchor.constraint(equalTo: spendingLabel.bottomAnchor, constant: 8),
            progressBar.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8),
            progressBar.heightAnchor.constraint(equalToConstant: 4) // Standard height for progress bars
        ])
    }
    
    /// Configures the cell with category data
    func configure(with category: Category, currencySymbol: String, displayProgressBar: Bool = true) {
        print("[CategoryCell] Configuring cell for category: \(category.name), Budget: \(category.budgetAmount), Emoji: \(category.emoji)")
        
        emojiLabel.text = category.emoji
        categoryLabel.text = category.name
        currentCategoryId = category.id // Save the category ID to verify later
        
        if displayProgressBar {
            progressBar.isHidden = false
            spendingLabel.isHidden = false
            
            // Fetch spending items based on the spendingItemIds in the category
            SpendingFirebaseManager.shared.fetchSpendingItemsByIds(spendingItemIds: category.spendingItemIds) { [weak self] spendingItems in
                guard let self = self else { return }
                
                // Verify that the fetched data is still for the correct category
                guard self.currentCategoryId == category.id else {
                    print("[CategoryCell] Skipping UI update for category: \(category.name) as the cell was reused.")
                    return
                }
                
                let totalSpent = category.calculateTotalSpent(using: spendingItems)
                print("[CategoryCell] Async fetch for category: \(category.name), Total Spent: \(totalSpent), Budget: \(category.budgetAmount)")
                
                DispatchQueue.main.async {
                    self.spendingLabel.text = "\(currencySymbol)\(totalSpent) / \(currencySymbol)\(category.budgetAmount)"
                    self.progressBar.progress = category.budgetAmount > 0 ? Float(totalSpent / category.budgetAmount) : 0
                    print("[CategoryCell] UI updated for category: \(category.name), Spending Label: \(self.spendingLabel.text ?? ""), Progress: \(self.progressBar.progress)")
                }
            }
        } else {
            print("[CategoryCell] Hiding progress bar and spending label for category: \(category.name)")
            progressBar.isHidden = true
            spendingLabel.isHidden = true
        }
    }
}
