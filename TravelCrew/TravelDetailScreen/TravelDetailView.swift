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
    var labelCurrency: UILabel!
    var labelCreatorName: UILabel! // New label for creator's name
    var buttonPackingList: UIButton!
    var buttonInviteFriend: UIButton!
    var buttonSpending: UIButton!
    var buttonBillboard: UIButton!
    var labelFriendsList: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        setupLabelTravelTitle()
        setupLabelDateRange()
        setupLabelCountryAndCity()
        setupLabelCurrency()
        setupLabelCreatorName()
        setupButtonPackingList()
        setupButtonInviteFriend()
        setupButtonBillboard()
        setupButtonSpending()
        setupLabelFriendsList()
        
        initConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    func setupLabelCurrency() {
        labelCurrency = UILabel()
        labelCurrency.font = UIFont.systemFont(ofSize: 16)
        labelCurrency.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(labelCurrency)
    }
    
    func setupButtonPackingList() {
        buttonPackingList = UIButton(type: .system)
        buttonPackingList.setTitle("Packing List", for: .normal)
        buttonPackingList.backgroundColor = .systemBlue
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
    
    func setupButtonSpending() {
        buttonSpending = UIButton(type: .system)
        buttonSpending.setTitle("Spending", for: .normal)
        buttonSpending.backgroundColor = .systemBlue
        buttonSpending.setTitleColor(.white, for: .normal)
        buttonSpending.layer.cornerRadius = 8
        buttonSpending.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(buttonSpending)
    }
    
    func setupButtonBillboard() {
        buttonBillboard = UIButton(type: .system)
        buttonBillboard.setTitle("Billboard", for: .normal)
        buttonBillboard.backgroundColor = .systemBlue
        buttonBillboard.setTitleColor(.white, for: .normal)
        buttonBillboard.layer.cornerRadius = 8
        buttonBillboard.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(buttonBillboard)
    }
    
    func setupLabelCreatorName() {
           labelCreatorName = UILabel()
           labelCreatorName.font = UIFont.systemFont(ofSize: 16)
           labelCreatorName.translatesAutoresizingMaskIntoConstraints = false
           self.addSubview(labelCreatorName)
    }
    
    func setupLabelFriendsList() {
        labelFriendsList = UILabel()
        labelFriendsList.font = UIFont.systemFont(ofSize: 16)
        labelFriendsList.numberOfLines = 0
        labelFriendsList.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(labelFriendsList)
    }

    
    func initConstraints() {
        NSLayoutConstraint.activate([
            labelTravelTitle.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20),
            labelTravelTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            labelTravelTitle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),

            labelCreatorName.topAnchor.constraint(equalTo: labelTravelTitle.bottomAnchor, constant: 20),
            labelCreatorName.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            labelCreatorName.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            labelDateRange.topAnchor.constraint(equalTo: labelCreatorName.bottomAnchor, constant: 20),
            labelDateRange.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            labelDateRange.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),

            labelCountryAndCity.topAnchor.constraint(equalTo: labelDateRange.bottomAnchor, constant: 20),
            labelCountryAndCity.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            labelCountryAndCity.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),

            labelCurrency.topAnchor.constraint(equalTo: labelCountryAndCity.bottomAnchor, constant: 20),
            labelCurrency.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            labelCurrency.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            buttonPackingList.topAnchor.constraint(equalTo: labelCurrency.bottomAnchor, constant: 20),
            buttonPackingList.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            buttonPackingList.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            buttonPackingList.heightAnchor.constraint(equalToConstant: 44),

            
            buttonSpending.topAnchor.constraint(equalTo: buttonPackingList.bottomAnchor, constant: 20),
            buttonSpending.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            buttonSpending.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            buttonSpending.heightAnchor.constraint(equalToConstant: 44),
            
            buttonBillboard.topAnchor.constraint(equalTo: buttonSpending.bottomAnchor, constant: 20),
            buttonBillboard.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            buttonBillboard.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            buttonBillboard.heightAnchor.constraint(equalToConstant: 44),
            
            labelFriendsList.topAnchor.constraint(equalTo: buttonBillboard.bottomAnchor, constant: 30),
            labelFriendsList.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            labelFriendsList.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            buttonInviteFriend.topAnchor.constraint(equalTo: labelFriendsList.bottomAnchor, constant: 20),
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
        labelCreatorName.text = "Created by \(travel.creatorName)"
        labelCurrency.text = "Currency: \(travel.currency)" 
        labelFriendsList.text = "Participants: \(travel.participantNames.joined(separator: ", "))"
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
}
