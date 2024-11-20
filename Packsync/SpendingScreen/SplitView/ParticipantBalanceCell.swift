//
//  ParticipantBalanceCell.swift
//  Packsync
//
//  Created by Leo Yang on 11/19/24.
//

import UIKit

class ParticipantBalanceCell: UITableViewCell {
    
    private let nameLabel = UILabel()
    private let balanceLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        // Configure nameLabel
        nameLabel.font = .boldSystemFont(ofSize: 16)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        
        // Configure balanceLabel
        balanceLabel.font = .systemFont(ofSize: 16)
        balanceLabel.textAlignment = .right
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(balanceLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            balanceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            balanceLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    func configure(with participant: User, balance: Balance) {
        nameLabel.text = participant.displayName ?? participant.email
        
        if let amount = balance.balances[participant.id] {
            let formattedAmount = String(format: "%.2f", abs(amount))
            balanceLabel.text = amount >= 0 ? "+\(formattedAmount)" : "-\(formattedAmount)"
            balanceLabel.textColor = amount >= 0 ? .systemGreen : .systemRed
        } else {
            balanceLabel.text = "N/A"
            balanceLabel.textColor = .gray
        }
    }
}
