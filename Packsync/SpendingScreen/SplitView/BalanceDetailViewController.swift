import UIKit

class BalanceDetailViewController: UIViewController {
    private var balance: Balance
    private var participants: [User] // Add this property
    private let tableView = UITableView()
    
    init(balance: Balance, participants: [User]) { // Add participants to the initializer
        self.balance = balance
        self.participants = participants
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Balance Details"
        view.backgroundColor = .white
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.register(ParticipantBalanceCell.self, forCellReuseIdentifier: "ParticipantBalanceCell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension BalanceDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return balance.balances.count // Assuming 'balances' is the dictionary of user balances
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParticipantBalanceCell", for: indexPath) as! ParticipantBalanceCell
        
        // Get the participant's balance entry at the current index
        let sortedBalances = balance.balances.sorted { $0.value > $1.value } // Sort balances descending for clarity
        let debtorId = sortedBalances[indexPath.row].key
        let amount = sortedBalances[indexPath.row].value

        if amount > 0, // Only consider positive balances as debtors
           let debtor = participants.first(where: { $0.id == debtorId }),
           let creditor = participants.first(where: { balance.balances[$0.id] == -amount }) {
            // Configure the cell with the debtor, creditor, and absolute amount
            cell.configure(with: (debtor: debtor, creditor: creditor, amount: abs(amount)))
        } else {
            // Handle case where no matching creditor is found
            let placeholderUser = User(id: debtorId, email: "Unknown", password: "")
            let creditor = User(id: "unknown-creditor", email: "Unknown Creditor", password: "")
            cell.configure(with: (debtor: placeholderUser, creditor: creditor, amount: abs(amount)))
        }

        return cell
    }
}
