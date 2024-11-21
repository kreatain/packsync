//
//  TransactionCell.swift
//  Packsync
//

import UIKit

class TransactionCell: UITableViewCell {
    private let debtorIcon = UIImageView()
    private let creditorIcon = UIImageView()
    private let debtorLabel = UILabel()
    private let creditorLabel = UILabel()
    private let amountLabel = UILabel()
    private let arrowLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        // Configure icons
        [debtorIcon, creditorIcon].forEach {
            $0.contentMode = .scaleAspectFill
            $0.layer.cornerRadius = 20
            $0.layer.masksToBounds = true
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        // Configure labels
        [debtorLabel, creditorLabel].forEach {
            $0.font = .systemFont(ofSize: 14, weight: .medium)
            $0.textColor = .black
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        arrowLabel.font = .systemFont(ofSize: 18)
        arrowLabel.text = "➡️"
        arrowLabel.textAlignment = .center
        arrowLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(arrowLabel)
        
        amountLabel.font = .boldSystemFont(ofSize: 16)
        amountLabel.textColor = .systemGreen
        amountLabel.textAlignment = .center
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(amountLabel)
        
        // Add constraints
        NSLayoutConstraint.activate([
            // Icons
            debtorIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            debtorIcon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            debtorIcon.widthAnchor.constraint(equalToConstant: 40),
            debtorIcon.heightAnchor.constraint(equalToConstant: 40),
            
            creditorIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            creditorIcon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            creditorIcon.widthAnchor.constraint(equalToConstant: 40),
            creditorIcon.heightAnchor.constraint(equalToConstant: 40),
            
            // Labels
            debtorLabel.topAnchor.constraint(equalTo: debtorIcon.bottomAnchor, constant: 5),
            debtorLabel.centerXAnchor.constraint(equalTo: debtorIcon.centerXAnchor),
            
            creditorLabel.topAnchor.constraint(equalTo: creditorIcon.bottomAnchor, constant: 5),
            creditorLabel.centerXAnchor.constraint(equalTo: creditorIcon.centerXAnchor),
            
            // Arrow Label
            arrowLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            arrowLabel.centerYAnchor.constraint(equalTo: debtorIcon.centerYAnchor),
            
            // Amount Label
            amountLabel.topAnchor.constraint(equalTo: arrowLabel.bottomAnchor, constant: 5),
            amountLabel.centerXAnchor.constraint(equalTo: arrowLabel.centerXAnchor),
            
            // Content View Padding
            contentView.bottomAnchor.constraint(greaterThanOrEqualTo: amountLabel.bottomAnchor, constant: 15)
        ])
    }
    
    func configure(with transaction: (debtor: User, creditor: User, amount: Double), debtorIconImage: UIImage?, creditorIconImage: UIImage?) {
        debtorIcon.image = debtorIconImage ?? UIImage(systemName: "person.circle")
        creditorIcon.image = creditorIconImage ?? UIImage(systemName: "person.circle")
        debtorLabel.text = transaction.debtor.displayName ?? transaction.debtor.email
        creditorLabel.text = transaction.creditor.displayName ?? transaction.creditor.email
        amountLabel.text = String(format: "%.2f", transaction.amount)
    }
}
