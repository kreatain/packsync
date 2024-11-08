//
//  TravelView.swift
//  Packsync
//
//  Created by 许多 on 10/24/24.
//

import UIKit

class TravelView: UIView {
    
    var tableViewTravelPlans: UITableView!
    
    var labelText1: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        setupTableViewTravelPlans()
        setupLabelText1()
        initConstraints()
    }
    
    func setupLabelText1() {
        labelText1 = UILabel()
        labelText1.font = .boldSystemFont(ofSize: 18)
        labelText1.textAlignment = .center
        labelText1.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(labelText1)
    }
    
    func setupTableViewTravelPlans(){
        tableViewTravelPlans = UITableView()
        tableViewTravelPlans.register(TravelPlanTableViewCell.self, forCellReuseIdentifier: Configs.tableViewTravelPlansID)
        tableViewTravelPlans.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(tableViewTravelPlans)
    }

    func initConstraints(){
        NSLayoutConstraint.activate([
            labelText1.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 8),
            labelText1.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            labelText1.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            
            tableViewTravelPlans.topAnchor.constraint(equalTo: labelText1.bottomAnchor, constant: 8),
            tableViewTravelPlans.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tableViewTravelPlans.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tableViewTravelPlans.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
