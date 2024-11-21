//
//  ParticipantSelectorViewController.swift
//  Packsync
//
//  Created by Leo Yang  on 11/19/24.
//

import UIKit


class ParticipantSelectorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var participants: [User]
    private var selectedParticipants: Set<String>
    weak var delegate: ParticipantSelectorDelegate?

    private let tableView = UITableView()

    init(participants: [User], selectedParticipants: Set<String>) {
        self.participants = participants
        if selectedParticipants.isEmpty {
            // Default to select all participants
            self.selectedParticipants = Set(participants.map { $0.id })
        } else {
            self.selectedParticipants = selectedParticipants
        }
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    private func setupTableView() {
        view.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ParticipantSelectorCell.self, forCellReuseIdentifier: "ParticipantSelectorCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participants.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ParticipantSelectorCell", for: indexPath) as? ParticipantSelectorCell else {
            fatalError("Could not dequeue ParticipantSelectorCell")
        }
        let participant = participants[indexPath.row]
        let isChecked = selectedParticipants.contains(participant.id)
        cell.configure(with: participant.displayName ?? participant.email, isChecked: isChecked)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let participant = participants[indexPath.row]
        if selectedParticipants.contains(participant.id) {
            selectedParticipants.remove(participant.id)
        } else {
            selectedParticipants.insert(participant.id)
        }
        delegate?.didUpdateSelectedParticipants(selectedParticipants)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
