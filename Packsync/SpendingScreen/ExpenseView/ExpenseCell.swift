//
//  ExpenseCell.swift
//  Packsync
//
//  Created by Leo Yang on 11/18/24.
//

import UIKit

class ExpenseCell: UITableViewCell {
    private let emojiLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let amountLabel = UILabel()
    private let userIconView = UIImageView()
    private let dateLabel = UILabel()
    private let receiptIndicatorLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // Emoji Label
        emojiLabel.font = .systemFont(ofSize: 30)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emojiLabel)
        
        // Description Label
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.textColor = .black
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
        
        // Amount Label
        amountLabel.font = .boldSystemFont(ofSize: 16)
        amountLabel.textColor = .systemGreen
        amountLabel.textAlignment = .right
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(amountLabel)
        
        // User Icon
        userIconView.contentMode = .scaleAspectFill
        userIconView.layer.cornerRadius = 20
        userIconView.layer.masksToBounds = true
        userIconView.clipsToBounds = true
        userIconView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(userIconView)
        
        // Date Label
        dateLabel.font = .systemFont(ofSize: 14)
        dateLabel.textColor = .gray
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateLabel)
        
        // Receipt Indicator Label
        receiptIndicatorLabel.font = .systemFont(ofSize: 12)
        receiptIndicatorLabel.textColor = .lightGray // Use a lighter color
        receiptIndicatorLabel.textAlignment = .left // Align with the column
        receiptIndicatorLabel.translatesAutoresizingMaskIntoConstraints = false
        receiptIndicatorLabel.isHidden = true // Initially hidden
        contentView.addSubview(receiptIndicatorLabel)
        
        // Layout constraints
        NSLayoutConstraint.activate([
           emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
           emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
           emojiLabel.widthAnchor.constraint(equalToConstant: 40),

           userIconView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
           userIconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
           userIconView.widthAnchor.constraint(equalToConstant: 40),
           userIconView.heightAnchor.constraint(equalToConstant: 40),

           amountLabel.trailingAnchor.constraint(equalTo: userIconView.leadingAnchor, constant: -10),
           amountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
           amountLabel.widthAnchor.constraint(equalToConstant: 80),

           descriptionLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 10),
           descriptionLabel.trailingAnchor.constraint(equalTo: amountLabel.leadingAnchor, constant: -10),
           descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),

           dateLabel.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
           dateLabel.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor),
           dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 5),

           receiptIndicatorLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
           receiptIndicatorLabel.trailingAnchor.constraint(equalTo: dateLabel.trailingAnchor),
           receiptIndicatorLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 2) 
       ])
    }

    func configure(with expense: SpendingItem, categoryEmoji: String, userIcon: UIImage?, dateString: String, hasReceipt: Bool) {
        // Set the emoji
        emojiLabel.text = categoryEmoji

        // Set the description and amount
        descriptionLabel.text = expense.description
        amountLabel.text = "\(expense.amount)"

        // Set the user icon
        userIconView.image = userIcon ?? UIImage(systemName: "person.circle")

        // Set the date string
        dateLabel.text = dateString

        // Set the receipt indicator
        if hasReceipt {
            receiptIndicatorLabel.text = "Receipt"
            receiptIndicatorLabel.isHidden = false
        } else {
            receiptIndicatorLabel.isHidden = true
        }
    }
    
}
