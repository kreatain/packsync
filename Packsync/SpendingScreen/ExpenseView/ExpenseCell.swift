//
//  ExpenseCell.swift
//  Packsync
//

import UIKit

class ExpenseCell: UITableViewCell {
    private let emojiLabel = UILabel()
    private let amountLabel = UILabel()
    private let userIconView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        emojiLabel.font = .systemFont(ofSize: 24)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false

        amountLabel.font = .systemFont(ofSize: 16, weight: .bold)
        amountLabel.translatesAutoresizingMaskIntoConstraints = false

        userIconView.layer.cornerRadius = 16
        userIconView.clipsToBounds = true
        userIconView.contentMode = .scaleAspectFill
        userIconView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(emojiLabel)
        contentView.addSubview(amountLabel)
        contentView.addSubview(userIconView)

        NSLayoutConstraint.activate([
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            amountLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 16),
            amountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            userIconView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            userIconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            userIconView.widthAnchor.constraint(equalToConstant: 32),
            userIconView.heightAnchor.constraint(equalToConstant: 32),
        ])
    }

    func configure(with expense: SpendingItem, categoryEmoji: String, userIcon: UIImage?) {
        emojiLabel.text = categoryEmoji
        amountLabel.text = "\(expense.amount)"
        userIconView.image = userIcon ?? UIImage(systemName: "person.circle")
    }
}
