import UIKit

class SpendingView: UIView {
    let travelTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let tabBar: UISegmentedControl = {
        let tab = UISegmentedControl(items: ["Overview", "Budget", "Expenses", "Split"])
        tab.selectedSegmentIndex = 0
        tab.translatesAutoresizingMaskIntoConstraints = false
        return tab
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(travelTitleLabel)
        addSubview(tabBar)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Title Label Constraints - positioned within the safe area
            travelTitleLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20),
            travelTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            travelTitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),

            // Tab Bar Constraints - just below the title
            tabBar.topAnchor.constraint(equalTo: travelTitleLabel.bottomAnchor, constant: 10),
            tabBar.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            tabBar.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            tabBar.bottomAnchor.constraint(lessThanOrEqualTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -10) // Optional for full-screen expansion
        ])
    }
    
    // Configure the title with the travel plan name
    func configure(with travel: Travel) {
        travelTitleLabel.text = "Spending Plan: \(travel.travelTitle)"
    }
}
