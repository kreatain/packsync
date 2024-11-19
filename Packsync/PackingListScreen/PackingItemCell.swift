//
//  PackingItemCell.swift
//  Packsync
//
//  Created by Xi Jia on 11/13/24.
//

import UIKit

class PackingItemCell: UITableViewCell {
    var nameLabel: UILabel!
    var checkboxButton: UIButton!
    var packedByLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        checkboxButton = UIButton(type: .custom)
        checkboxButton.translatesAutoresizingMaskIntoConstraints = false
        checkboxButton.setImage(UIImage(systemName: "square"), for: .normal)
        checkboxButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        contentView.addSubview(checkboxButton)
        
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        contentView.addSubview(nameLabel)
        
        packedByLabel = UILabel()
        packedByLabel.translatesAutoresizingMaskIntoConstraints = false
        packedByLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        packedByLabel.textColor = .gray
        contentView.addSubview(packedByLabel)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            checkboxButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkboxButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkboxButton.widthAnchor.constraint(equalToConstant: 24),
            checkboxButton.heightAnchor.constraint(equalToConstant: 24),
            
            nameLabel.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            packedByLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            packedByLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            packedByLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            packedByLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with item: PackingItem) {
        nameLabel.text = "\(item.name) (count: \(item.itemNumber))"
        checkboxButton.isSelected = item.isPacked
        
        if let packedBy = item.isPackedBy, item.isPacked {
            packedByLabel.text = "Packed by: \(packedBy)"
            packedByLabel.isHidden = false
        } else {
            packedByLabel.isHidden = true
        }
    }
}
