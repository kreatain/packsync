//
//  ExpenseDetailsViewController.swift
//  Packsync
//
//  Created by Xu Yang on 11/15/24.
//

import UIKit

class ExpenseDetailsViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let descriptionLabel = UILabel()
    private let categoryLabel = UILabel()
    private let amountLabel = UILabel()
    private let spentByLabel = UILabel()
    private let dateLabel = UILabel()
    private let receiptImageView = UIImageView()
    
    private var expense: SpendingItem
    private var category: Category
    private var spender: User?
    private var currencySymbol: String

    init(expense: SpendingItem, category: Category, spender: User?, currencySymbol: String) {
        self.expense = expense
        self.category = category
        self.spender = spender
        self.currencySymbol = currencySymbol
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWithExpense()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure Labels
        descriptionLabel.font = .boldSystemFont(ofSize: 18)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        categoryLabel.font = .systemFont(ofSize: 16)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        amountLabel.font = .systemFont(ofSize: 16)
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        spentByLabel.font = .systemFont(ofSize: 16)
        spentByLabel.translatesAutoresizingMaskIntoConstraints = false
        
        dateLabel.font = .systemFont(ofSize: 16)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        receiptImageView.contentMode = .scaleAspectFit
        receiptImageView.translatesAutoresizingMaskIntoConstraints = false
        receiptImageView.isUserInteractionEnabled = true
        receiptImageView.isHidden = true // Initially hidden
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewReceiptFullscreen))
        receiptImageView.addGestureRecognizer(tapGesture)
        
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(amountLabel)
        contentView.addSubview(spentByLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(receiptImageView)
        
        // Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            categoryLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            amountLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 20),
            amountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            spentByLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 20),
            spentByLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            dateLabel.topAnchor.constraint(equalTo: spentByLabel.bottomAnchor, constant: 20),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            receiptImageView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            receiptImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            receiptImageView.widthAnchor.constraint(equalToConstant: 200),
            receiptImageView.heightAnchor.constraint(equalToConstant: 200),
            receiptImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func configureWithExpense() {
        descriptionLabel.text = "Description: \(expense.description)"
        categoryLabel.text = "Category: \(category.name)"
        amountLabel.text = "Amount: \(currencySymbol)\(String(format: "%.2f", expense.amount))"
        spentByLabel.text = "Spent By: \(spender?.displayName ?? spender?.email ?? "Unknown")"
        dateLabel.text = "Date: \(formattedDate(from: expense.date))"
        
        if let receiptURLString = expense.receiptURL, let receiptURL = URL(string: receiptURLString) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: receiptURL), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.receiptImageView.image = image
                        self.receiptImageView.isHidden = false // Show only when image loads
                    }
                }
            }
        }
    }
    
    private func formattedDate(from isoDate: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: isoDate) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.string(from: date)
        }
        return isoDate // Fallback if parsing fails
    }
    
    @objc private func viewReceiptFullscreen() {
        guard let image = receiptImageView.image else { return }
        let fullscreenVC = FullscreenImageViewController(image: image)
        present(fullscreenVC, animated: true, completion: nil)
    }
}
