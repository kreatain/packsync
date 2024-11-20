import UIKit

class ParticipantSelectorCell: UITableViewCell {
    private let checkboxImageView = UIImageView()
    private let nameLabel = UILabel()
    var isChecked = false {
        didSet {
            updateCheckboxAppearance()
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Configure checkboxImageView
        checkboxImageView.contentMode = .scaleAspectFit
        checkboxImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(checkboxImageView)
        
        // Configure nameLabel
        nameLabel.font = .systemFont(ofSize: 16)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        
        // Constraints
        NSLayoutConstraint.activate([
            checkboxImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkboxImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkboxImageView.widthAnchor.constraint(equalToConstant: 24),
            checkboxImageView.heightAnchor.constraint(equalToConstant: 24),
            
            nameLabel.leadingAnchor.constraint(equalTo: checkboxImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        // Initial appearance
        updateCheckboxAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with name: String, isChecked: Bool) {
        nameLabel.text = name
        self.isChecked = isChecked
    }

    private func updateCheckboxAppearance() {
        let imageName = isChecked ? "checkmark.circle.fill" : "circle"
        checkboxImageView.image = UIImage(systemName: imageName)
        checkboxImageView.tintColor = isChecked ? .systemBlue : .lightGray
    }
}
