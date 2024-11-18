//
//  InviteFriendView.swift
//  Packsync
//
//  Created by Jessica on 10/24/24.
//

import UIKit

class InviteFriendView: UIView {
    var textFieldEmail: UITextField!
    var buttonSendInvitation: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        setupTextFieldEmail()
        setupButtonSendInvitation()
        initConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupTextFieldEmail() {
        textFieldEmail = UITextField()
        textFieldEmail.placeholder = "Enter friend's email"
        textFieldEmail.borderStyle = .roundedRect
        textFieldEmail.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(textFieldEmail)
    }

    func setupButtonSendInvitation() {
        buttonSendInvitation = UIButton(type: .system)
        buttonSendInvitation.setTitle("Send Invitation", for: .normal)
        buttonSendInvitation.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(buttonSendInvitation)
    }

    func initConstraints() {
        NSLayoutConstraint.activate([
            textFieldEmail.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20),
            textFieldEmail.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            textFieldEmail.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),

            buttonSendInvitation.topAnchor.constraint(equalTo: textFieldEmail.bottomAnchor, constant: 20),
            buttonSendInvitation.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    }
}
