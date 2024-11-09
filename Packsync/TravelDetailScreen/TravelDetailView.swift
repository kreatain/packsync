//
//  TravelDetailView.swift
//  Packsync
//
//  Created by Xi Jia on 11/8/24.
//

import UIKit

class TravelDetailView: UIView {
    
    var labelTravelTitle: UILabel!
    var labelDateRange: UILabel!
    var labelCountryAndCity: UILabel!
    
    var buttonPackingList: UIButton!
    var buttonInviteFriend: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        setupLabelTravelTitle()
        setupLabelDateRange()
        setupLabelCountryAndCity()
        
        setupButtonPackingList()
        setupButtonInviteFriend()
        
        initConstraints()
    }
    
    func setupLabelTravelTitle() {
        labelTravelTitle = UILabel()
        labelTravelTitle.font = UIFont.boldSystemFont(ofSize: 20)
        labelTravelTitle.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(labelTravelTitle)
    }
    
    func setupLabelDateRange() {
        labelDateRange = UILabel()
        labelDateRange.font = UIFont.systemFont(ofSize: 16)
        labelDateRange.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(labelDateRange)
    }
    
    func setupLabelCountryAndCity() {
        labelCountryAndCity = UILabel()
        labelCountryAndCity.font = UIFont.systemFont(ofSize: 16)
        labelCountryAndCity.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(labelCountryAndCity)
    }
    
    func setupButtonPackingList() {
        buttonPackingList = UIButton(type: .system)
        buttonPackingList.setTitle("Packing List", for: .normal)
        buttonPackingList.backgroundColor = .systemGreen
        buttonPackingList.setTitleColor(.white, for: .normal)
        buttonPackingList.layer.cornerRadius = 8
        buttonPackingList.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(buttonPackingList)
    }
    
    func setupButtonInviteFriend() {
        buttonInviteFriend = UIButton(type: .system)
        buttonInviteFriend.setTitle("Invite Friend", for: .normal)
        buttonInviteFriend.backgroundColor = .systemGreen
        buttonInviteFriend.setTitleColor(.white, for: .normal)
        buttonInviteFriend.layer.cornerRadius = 8
        buttonInviteFriend.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(buttonInviteFriend)
    }

    
    func initConstraints() {
        NSLayoutConstraint.activate([
            labelTravelTitle.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20),
            labelTravelTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            labelTravelTitle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            labelDateRange.topAnchor.constraint(equalTo: labelTravelTitle.bottomAnchor, constant: 20),
            labelDateRange.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            labelDateRange.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            labelCountryAndCity.topAnchor.constraint(equalTo: labelDateRange.bottomAnchor, constant: 20),
            labelCountryAndCity.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            labelCountryAndCity.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            buttonPackingList.topAnchor.constraint(equalTo: labelCountryAndCity.bottomAnchor, constant: 20),
            buttonPackingList.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            buttonPackingList.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            buttonPackingList.heightAnchor.constraint(equalToConstant: 44),
            
            buttonInviteFriend.topAnchor.constraint(equalTo: buttonPackingList.bottomAnchor, constant: 20),
            buttonInviteFriend.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            buttonInviteFriend.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            buttonInviteFriend.heightAnchor.constraint(equalToConstant: 44),
            buttonInviteFriend.bottomAnchor.constraint(lessThanOrEqualTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    func configure(with travel: Travel) {
        labelTravelTitle.text = "Travel Title: \(travel.travelTitle)"
        labelDateRange.text = "Travel Date: \(formatDate(travel.travelStartDate)) - \(formatDate(travel.travelEndDate))"
        labelCountryAndCity.text = "Country and City: \(travel.countryAndCity)"
    }
    
    func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "MMM dd, yyyy HH:mm"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        
        return dateString // Return original string if parsing fails
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
