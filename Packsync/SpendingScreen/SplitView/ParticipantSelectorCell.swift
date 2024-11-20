import UIKit

class ParticipantSelectorCell: UITableViewCell {
    private let nameLabel = UILabel()
    private let checkbox = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 16)
        nameLabel.textColor = .black
        contentView.addSubview(nameLabel)

        checkbox.translatesAutoresizingMaskIntoConstraints = false
        checkbox.contentMode = .scaleAspectFit
        contentView.addSubview(checkbox)

        NSLayoutConstraint.activate([
            checkbox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkbox.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkbox.widthAnchor.constraint(equalToConstant: 24),
            checkbox.heightAnchor.constraint(equalToConstant: 24),

            nameLabel.leadingAnchor.constraint(equalTo: checkbox.trailingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configure(with participantName: String, isChecked: Bool) {
        nameLabel.text = participantName
        checkbox.image = isChecked ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")
        checkbox.tintColor = isChecked ? .systemBlue : .lightGray
    }
}