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
        let participantId = Array(balance.balances.keys)[indexPath.row]
        
        if let participant = participants.first(where: { $0.id == participantId }) {
            cell.configure(with: participant, balance: balance)
        } else {
            // Handle the case where the participant is not found
            let placeholderUser = User(id: participantId, email: "Unknown", password: "")
            cell.configure(with: placeholderUser, balance: balance)
        }
        
        return cell
    }
}
