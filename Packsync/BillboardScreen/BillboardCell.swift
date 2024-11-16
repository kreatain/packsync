import UIKit

class BillboardCell: UITableViewCell {

    // UI Components
    private let noticeLabel = UILabel()
    private let titleLabel = UILabel()
    private let contentLabel = UILabel()
    private let containerView = UIView()
    private let titleStackView = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // Configure container view
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        containerView.layer.cornerRadius = 8
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)

        // Configure noticeLabel
        noticeLabel.text = "Notice"
        noticeLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        noticeLabel.textColor = .gray
        noticeLabel.textAlignment = .left
        noticeLabel.translatesAutoresizingMaskIntoConstraints = false

        // Configure titleLabel
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textColor = .gray
        titleLabel.textAlignment = .right
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Configure contentLabel
        contentLabel.font = UIFont.systemFont(ofSize: 16)
        contentLabel.numberOfLines = 0
        contentLabel.translatesAutoresizingMaskIntoConstraints = false

        // Configure stack view for the title line
        titleStackView.axis = .horizontal
        titleStackView.alignment = .fill
        titleStackView.distribution = .equalSpacing
        titleStackView.addArrangedSubview(noticeLabel)
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleStackView)

        // Add contentLabel to containerView
        containerView.addSubview(contentLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container view constraints
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            // Stack view constraints
            titleStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            titleStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            titleStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),

            // Content label constraints
            contentLabel.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 4),
            contentLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            contentLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            contentLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
    }

    // Configure the cell with data
    func configure(noticeTitle: String, authorAndDate: String, content: String) {
        titleLabel.text = authorAndDate
        contentLabel.text = content
    }
}
