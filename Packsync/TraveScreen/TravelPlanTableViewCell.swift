import UIKit

protocol TravelPlanTableViewCellDelegate: AnyObject {
    func setActivePlanButtonTapped(_ travelPlan: Travel)
    func editTravelPlanTapped(_ travelPlan: Travel)
    func deleteTravelPlanTapped(_ travelPlan: Travel)
}

class TravelPlanTableViewCell: UITableViewCell {
    weak var delegate: TravelPlanTableViewCellDelegate?
    var travelPlan: Travel?
    
    var wrapperCellView: UIView!
    var labelTravelTitle: UILabel!
    var labelDateRange: UILabel!
    var labelCountryAndCity: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupWrapperCellView()
        setupLabelTravelTitle()
        setupLabelDateRange()
        setupLabelCountryAndCity()
        initConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupWrapperCellView() {
        wrapperCellView = UIView()
        wrapperCellView.backgroundColor = .white
        wrapperCellView.layer.cornerRadius = 10
        wrapperCellView.layer.shadowColor = UIColor.gray.cgColor
        wrapperCellView.layer.shadowOffset = .zero
        wrapperCellView.layer.shadowRadius = 4
        wrapperCellView.layer.shadowOpacity = 0.4
        wrapperCellView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(wrapperCellView)
    }
    
    func setupLabelTravelTitle() {
        labelTravelTitle = UILabel()
        labelTravelTitle.font = UIFont.boldSystemFont(ofSize: 14)
        labelTravelTitle.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(labelTravelTitle)
    }
    
    func setupLabelDateRange() {
        labelDateRange = UILabel()
        labelDateRange.font = UIFont.systemFont(ofSize: 10)
        labelDateRange.textColor = .darkGray
        labelDateRange.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(labelDateRange)
    }
    
    func setupLabelCountryAndCity() {
        labelCountryAndCity = UILabel()
        labelCountryAndCity.font = UIFont.systemFont(ofSize: 10)
        labelCountryAndCity.textColor = .darkGray
        labelCountryAndCity.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(labelCountryAndCity)
    }
    
    func initConstraints() {
        NSLayoutConstraint.activate([
            wrapperCellView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            wrapperCellView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            wrapperCellView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            wrapperCellView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
            
            labelTravelTitle.topAnchor.constraint(equalTo: wrapperCellView.topAnchor, constant: 8),
            labelTravelTitle.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor, constant: 16),
            labelTravelTitle.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -16),
            
            labelDateRange.topAnchor.constraint(equalTo: labelTravelTitle.bottomAnchor, constant: 8),
            labelDateRange.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor, constant: 16),
            labelDateRange.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -16),
            
            labelCountryAndCity.topAnchor.constraint(equalTo: labelDateRange.bottomAnchor, constant: 8),
            labelCountryAndCity.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor, constant: 16),
            labelCountryAndCity.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -16),
            labelCountryAndCity.bottomAnchor.constraint(equalTo: wrapperCellView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with travel: Travel) {
        self.travelPlan = travel
        labelTravelTitle.text = "Travel Plan: \(travel.travelTitle)"
        labelDateRange.text = "Travel Date: \(travel.travelStartDate) - \(travel.travelEndDate)"
        labelCountryAndCity.text = "Country and City: \(travel.countryAndCity)"
        
        // Set background color and shadow properties
        if isActiveTravelPlan(travel) {
            wrapperCellView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
        } else {
            wrapperCellView.backgroundColor = .white
        }
        
        // Apply shadow properties
        wrapperCellView.layer.shadowColor = UIColor.gray.cgColor
        wrapperCellView.layer.shadowOffset = CGSize(width: 0, height: 2)
        wrapperCellView.layer.shadowOpacity = 0.4
        wrapperCellView.layer.shadowRadius = 4
    }
    
    // Helper method to determine if the current travel plan is active
        private func isActiveTravelPlan(_ travel: Travel) -> Bool {
            return travel.id == TravelPlanManager.shared.activeTravelPlan?.id
        }

}
