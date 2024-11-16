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
        emojiLabel.text = category.emoji
        categoryLabel.text = category.name

        if displayProgressBar {
            progressBar.isHidden = false
            spendingLabel.isHidden = false
            
            // Fetch spending items based on the spendingItemIds in the category
            SpendingFirebaseManager.shared.fetchSpendingItemsByIds(spendingItemIds: category.spendingItemIds) { spendingItems in
                let totalSpent = category.calculateTotalSpent(using: spendingItems)
                DispatchQueue.main.async {
                    self.spendingLabel.text = "\(currencySymbol)\(totalSpent) / \(currencySymbol)\(category.budgetAmount)"
                    self.progressBar.progress = Float(totalSpent / category.budgetAmount)
                }
            }
        } else {
            progressBar.isHidden = true
            spendingLabel.isHidden = true
        }
    }
    
}
