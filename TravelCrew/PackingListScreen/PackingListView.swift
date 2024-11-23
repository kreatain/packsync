//
//  PackingListView.swift
//  Packsync
//
//  Created by Xi Jia on 11/8/24.
//

import UIKit

class PackingListView: UIView {
    
    var labelTravelTitle: UILabel!
    var tableViewPackingList: UITableView!
    var buttonAddPackingItem: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        setupLabelTravelTitle()
        setupTableViewPackingList()
        setupButtonAddPackingItem()
        
        initConstraints()
    }
    
    func setupLabelTravelTitle() {
        labelTravelTitle = UILabel()
        labelTravelTitle.font = UIFont.boldSystemFont(ofSize: 18)
        labelTravelTitle.textAlignment = .center
        labelTravelTitle.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(labelTravelTitle)
    }
    
    func setupTableViewPackingList() {
        tableViewPackingList = UITableView()
        tableViewPackingList.register(PackingItemCell.self, forCellReuseIdentifier: "PackingItemCell")
        tableViewPackingList.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(tableViewPackingList)
    }
    
    func setupButtonAddPackingItem() {
        buttonAddPackingItem = UIButton(type: .system)
        buttonAddPackingItem.setTitle("Add Packing Item", for: .normal)
        buttonAddPackingItem.setTitleColor(.white, for: .normal)
        buttonAddPackingItem.backgroundColor = .systemBlue
        buttonAddPackingItem.layer.cornerRadius = 8
        buttonAddPackingItem.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(buttonAddPackingItem)
    }
    
    func initConstraints() {
        NSLayoutConstraint.activate([
            labelTravelTitle.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20),
            labelTravelTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            labelTravelTitle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            tableViewPackingList.topAnchor.constraint(equalTo: labelTravelTitle.bottomAnchor, constant: 20),
            tableViewPackingList.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tableViewPackingList.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tableViewPackingList.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            
            buttonAddPackingItem.topAnchor.constraint(equalTo: tableViewPackingList.bottomAnchor, constant: 20),
            buttonAddPackingItem.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            buttonAddPackingItem.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            buttonAddPackingItem.heightAnchor.constraint(equalToConstant: 45),
            buttonAddPackingItem.bottomAnchor.constraint(lessThanOrEqualTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    func configure(with travel: Travel) {
        labelTravelTitle.text = "Packing List: \(travel.travelTitle)"
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
