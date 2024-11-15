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
    var profileImageView: UIImageView!
    
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
        
        profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 12 // Half of the width/height for circular image
        contentView.addSubview(profileImageView)
        
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
                    packedByLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
                    
                    profileImageView.leadingAnchor.constraint(equalTo: packedByLabel.trailingAnchor, constant: 4),
                    profileImageView.centerYAnchor.constraint(equalTo: packedByLabel.centerYAnchor),
                    profileImageView.widthAnchor.constraint(equalToConstant: 20),
                    profileImageView.heightAnchor.constraint(equalToConstant: 20),
                    profileImageView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16)
                ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: PackingItem) {
       nameLabel.text = "\(item.name) (count: \(item.itemNumber))"
       checkboxButton.isSelected = item.isPacked
       if let packedBy = item.isPackedBy, item.isPacked {
           print("Debug - PackedBy value: \(packedBy)")
           
           packedByLabel.text = "Packed by:"

           if let url = URL(string: packedBy) {
               URLSession.shared.dataTask(with: url) { (data, response, error) in
                   if let data = data, let image = UIImage(data: data) {
                       DispatchQueue.main.async {
                           self.profileImageView.image = image
                       }
                   } else {
                       DispatchQueue.main.async {
                           self.profileImageView.image = UIImage(systemName: "person.circle")
                       }
                   }
               }.resume()
           } else {
               profileImageView.image = UIImage(systemName: "person.circle")
           }
           packedByLabel.isHidden = false
           profileImageView.isHidden = false
       } else {
           packedByLabel.isHidden = true
           profileImageView.isHidden = true
       }
    }
}
