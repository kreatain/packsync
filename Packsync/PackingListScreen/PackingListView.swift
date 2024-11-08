//
//  PackingListView.swift
//  Packsync
//
//  Created by 许多 on 10/24/24.
//

import UIKit

class PackingListView: UIView {
    
    var labelTravelTitle: UILabel!
    var tableViewPackingList: UITableView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        setupLabelTravelTitle()
        setupTableViewPackingList()
        
        initConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLabelTravelTitle() {
        labelTravelTitle = UILabel()
        labelTravelTitle.font = UIFont.boldSystemFont(ofSize: 20)
        labelTravelTitle.textAlignment = .center
        labelTravelTitle.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(labelTravelTitle)
    }
    
    func setupTableViewPackingList() {
        tableViewPackingList = UITableView()
        tableViewPackingList.register(UITableViewCell.self, forCellReuseIdentifier: "PackingItemCell")
        tableViewPackingList.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(tableViewPackingList)
    }
    
    func initConstraints() {
        NSLayoutConstraint.activate([
            labelTravelTitle.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20),
            labelTravelTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            labelTravelTitle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            tableViewPackingList.topAnchor.constraint(equalTo: labelTravelTitle.bottomAnchor, constant: 20),
            tableViewPackingList.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tableViewPackingList.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tableViewPackingList.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func configure(with travel: Travel) {
        labelTravelTitle.text = "Packing List for: \(travel.travelTitle)"
        // You can add more configuration here if needed
    }
}
