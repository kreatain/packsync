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
            
            progressBar.leadingAnchor.constraint(equalTo: spendingLabel.trailingAnchor, constant: 16),
            progressBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            progressBar.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with category: Category, travelId: String, totalBudget: Double) {
        emojiLabel.text = category.emoji
        categoryLabel.text = category.name
        
        // Fetch spending items based on `spendingItemIds` and calculate total spent
        SpendingFirebaseManager.shared.fetchSpendingItems(for: travelId, categoryId: category.id) { spendingItems in
            let totalSpent = category.calculateTotalSpent(using: spendingItems)
            
            // Update UI elements
            DispatchQueue.main.async {
                self.spendingLabel.text = "$\(totalSpent) / $\(category.budgetAmount)"
                self.progressBar.progress = Float(totalSpent / category.budgetAmount)
            }
        }
    }
}
