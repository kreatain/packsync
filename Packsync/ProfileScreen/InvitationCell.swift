//
//  InvitationCell.swift
//  Packsync
//
//  Created by Jessica on 11/16/24.
//

import UIKit

class InvitationCell: UITableViewCell {

    // Labels and buttons
    let invitationLabel = UILabel()
    let acceptButton = UIButton(type: .system)
    let rejectButton = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // Configure label
        invitationLabel.translatesAutoresizingMaskIntoConstraints = false
        invitationLabel.numberOfLines = 0
        invitationLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        invitationLabel.textAlignment = .center // Center the label text
        contentView.addSubview(invitationLabel)

        // Configure accept button
        acceptButton.setTitle("Let's Go", for: .normal)
        acceptButton.backgroundColor = .systemGreen
        acceptButton.tintColor = .white
        acceptButton.layer.cornerRadius = 10 // Softer corner radius
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(acceptButton)

        // Configure reject button
        rejectButton.setTitle("Maybe Next Time", for: .normal)
        rejectButton.backgroundColor = .systemRed
        rejectButton.tintColor = .white
        rejectButton.layer.cornerRadius = 10 // Softer corner radius
        rejectButton.titleLabel?.numberOfLines = 0 // Allow wrapping of text
        rejectButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rejectButton)

        // Constraints
        NSLayoutConstraint.activate([
            // Invitation label
            invitationLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            invitationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            invitationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Accept button
            acceptButton.topAnchor.constraint(equalTo: invitationLabel.bottomAnchor, constant: 20), // Add spacing below the label
            acceptButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -60), // Shift left for centering with reject button
            acceptButton.widthAnchor.constraint(equalToConstant: 100),
            acceptButton.heightAnchor.constraint(equalToConstant: 40), // Increase height for better tap area

            // Reject button
            rejectButton.topAnchor.constraint(equalTo: invitationLabel.bottomAnchor, constant: 20), // Same top anchor as accept button
            rejectButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 60), // Shift right for centering with accept button
            rejectButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 130), // Allow reject button to grow
            rejectButton.heightAnchor.constraint(equalToConstant: 40), // Increase height for better tap area

            // Bottom anchor to ensure cell height adjusts
            rejectButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
