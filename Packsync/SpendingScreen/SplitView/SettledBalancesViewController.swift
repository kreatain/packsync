//
//  SettledBalancesViewController.swift
//  Packsync
//
//  Created by Leo Yang  on 11/19/24.
//


//
//  SettledBalancesViewController.swift
//  Packsync
//

import UIKit

class SettledBalancesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let tableView = UITableView()
    private var participants: [User] = []
    private var settledBalances: [Balance] = []
    
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
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettledBalanceCell")
    }
    
    func setBalances(_ balances: [Balance], participants: [User]) {
        self.settledBalances = balances
        self.participants = participants
        tableView.reloadData()
    }
    
    // MARK: - Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settledBalances.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettledBalanceCell", for: indexPath)
        let balance = settledBalances[indexPath.row]
        cell.textLabel?.text = "Settled Balance: \(balance.id)"
        cell.detailTextLabel?.text = "Created At: \(balance.createdAt)"
        return cell
    }
}