//
//  CurrentBalanceViewController.swift
//  Packsync
//
//  Created by Leo Yang  on 11/19/24.
//


//
//  CurrentBalanceViewController.swift
//  Packsync
//

import UIKit

class CurrentBalanceViewController: UIViewController, UITableViewDataSource {
    
    private let tableView = UITableView()
    private var participants: [User] = []
    private var balance: Balance?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.dataSource = self
        tableView.register(ParticipantBalanceCell.self, forCellReuseIdentifier: "ParticipantBalanceCell")
    }
    
    func setBalanceData(balance: Balance, participants: [User]) {
        self.balance = balance
        self.participants = participants
        tableView.reloadData()
    }
    
    // MARK: - Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        participants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParticipantBalanceCell", for: indexPath) as! ParticipantBalanceCell
        let participant = participants[indexPath.row]
        if let balance = balance {
            cell.configure(with: participant, balance: balance)
        }
        return cell
    }
}