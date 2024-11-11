//
//  TravelView.swift
//  Packsync
//
//  Created by Xi Jia on 11/7/24.
//

import UIKit

class TravelView: UIView {
    
    var tableViewTravelPlans: UITableView!
    
    var labelText: UILabel!
    
    var buttonAddTravelPlan: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        setupTableViewTravelPlans()
        setupLabelText()
        setupButtonAddTravelPlan()
        
        initConstraints()
    }
    
    func setupLabelText() {
        labelText = UILabel()
        labelText.font = .boldSystemFont(ofSize: 18)
        labelText.textAlignment = .center
        labelText.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(labelText)
    }
    
    func setupTableViewTravelPlans(){
        tableViewTravelPlans = UITableView()
        tableViewTravelPlans.register(TravelPlanTableViewCell.self, forCellReuseIdentifier: Configs.tableViewTravelPlansID)
        tableViewTravelPlans.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(tableViewTravelPlans)
    }
    
    func setupButtonAddTravelPlan() {
        buttonAddTravelPlan = UIButton(type: .system)
        buttonAddTravelPlan.setTitle("Add Travel Plan", for: .normal)
        buttonAddTravelPlan.backgroundColor = .systemBlue
        buttonAddTravelPlan.setTitleColor(.white, for: .normal)
        buttonAddTravelPlan.layer.cornerRadius = 8
        buttonAddTravelPlan.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(buttonAddTravelPlan)
    }

    func initConstraints(){
        NSLayoutConstraint.activate([
            labelText.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 8),
            labelText.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            labelText.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            
            tableViewTravelPlans.topAnchor.constraint(equalTo: labelText.bottomAnchor, constant: 16),
            tableViewTravelPlans.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tableViewTravelPlans.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tableViewTravelPlans.bottomAnchor.constraint(equalTo: buttonAddTravelPlan.topAnchor, constant: -16),
            
            buttonAddTravelPlan.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            buttonAddTravelPlan.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            buttonAddTravelPlan.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            buttonAddTravelPlan.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

