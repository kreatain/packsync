//
//  ProfileView.swift
//  Packsync
//
//  Created by Jessica on 10/24/24.
//

import UIKit

class ProfileView: UIView {
    var imageViewProfilePic: UIImageView!
    var buttonEditProfilePic: UIButton!
    var labelNameText: UILabel!
    var labelName: UILabel!
    var labelEmailText: UILabel!
    var labelEmail: UILabel!
    var tableViewInvitations: UITableView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        setupProfilePicture()
        setupLabels()
        setupTableView()
        initConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupProfilePicture() {
        imageViewProfilePic = UIImageView()
        imageViewProfilePic.contentMode = .scaleAspectFill
        imageViewProfilePic.layer.cornerRadius = 50
        imageViewProfilePic.clipsToBounds = true
        imageViewProfilePic.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageViewProfilePic)

        buttonEditProfilePic = UIButton(type: .system)
        buttonEditProfilePic.setTitle("Edit", for: .normal)
        buttonEditProfilePic.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(buttonEditProfilePic)
    }

    func setupLabels() {
        labelNameText = UILabel()
        labelNameText.text = "Name:"
        labelNameText.font = .systemFont(ofSize: 18)
        labelNameText.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(labelNameText)

        labelName = UILabel()
        labelName.font = .systemFont(ofSize: 18)
        labelName.textColor = .gray
        labelName.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(labelName)

        labelEmailText = UILabel()
        labelEmailText.text = "Email:"
        labelEmailText.font = .systemFont(ofSize: 18)
        labelEmailText.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(labelEmailText)

        labelEmail = UILabel()
        labelEmail.font = .systemFont(ofSize: 18)
        labelEmail.textColor = .gray
        labelEmail.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(labelEmail)
    }

    func setupTableView() {
        tableViewInvitations = UITableView()
        tableViewInvitations.register(UITableViewCell.self, forCellReuseIdentifier: "invitationCell")
        tableViewInvitations.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(tableViewInvitations)
    }

    func initConstraints() {
        NSLayoutConstraint.activate([
            imageViewProfilePic.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageViewProfilePic.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageViewProfilePic.widthAnchor.constraint(equalToConstant: 100),
            imageViewProfilePic.heightAnchor.constraint(equalToConstant: 100),

            buttonEditProfilePic.topAnchor.constraint(equalTo: imageViewProfilePic.bottomAnchor, constant: 10),
            buttonEditProfilePic.centerXAnchor.constraint(equalTo: self.centerXAnchor),

            // Set constraints for labels and buttons
            labelNameText.topAnchor.constraint(equalTo: buttonEditProfilePic.bottomAnchor, constant: 20),
            labelNameText.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),

            labelName.topAnchor.constraint(equalTo: buttonEditProfilePic.bottomAnchor, constant: 20),
            labelName.leadingAnchor.constraint(equalTo: labelNameText.trailingAnchor, constant: 5),


            labelEmailText.topAnchor.constraint(equalTo: labelName.bottomAnchor, constant: 10),
            labelEmailText.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),

            labelEmail.topAnchor.constraint(equalTo: labelName.bottomAnchor, constant: 10),
            labelEmail.leadingAnchor.constraint(equalTo: labelEmailText.trailingAnchor, constant: 5),

            tableViewInvitations.topAnchor.constraint(equalTo: labelEmail.bottomAnchor, constant: 20),
            tableViewInvitations.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tableViewInvitations.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tableViewInvitations.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
