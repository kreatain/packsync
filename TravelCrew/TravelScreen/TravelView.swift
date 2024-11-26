//
//  TravelView.swift
//  Packsync
//
//  Created by Xi Jia on 11/7/24.
//

import UIKit

protocol TravelViewDelegate: AnyObject {
    func didTapActivePlanButton()
    func didTapOtherPlansButton()
}

class TravelView: UIView {
    
    // UI Elements
    var tableViewTravelPlans: UITableView!
    var labelText: UILabel!
    var buttonAddTravelPlan: UIButton!
    var segmentedControlView: UIView!
    var activePlanButton: UIButton!
    var otherPlansButton: UIButton!
    var activePlanDetailView: UIView!
    var activePlanTitleLabel: UILabel!
    var activePlanDateLabel: UILabel!
    var activePlanLocationLabel: UILabel!
    var activePlanParticipantIdsLabel: UILabel!
    var activePlanDescriptionLabel: UILabel!
    var placeholderView: UIView!

    weak var delegate: TravelViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        // Setup UI components
        setupLabelText()
        setupSegmentedControl()
        setupTableViewTravelPlans()
        setupButtonAddTravelPlan()
        setupActivePlanDetailView()
        
        // Initialize constraints
        initConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Methods

    func setupLabelText() {
        labelText = UILabel()
        labelText.font = .boldSystemFont(ofSize: 18)
        labelText.textAlignment = .center
        labelText.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(labelText)
    }
    
    func setupSegmentedControl() {
        segmentedControlView = UIView()
        segmentedControlView.backgroundColor = .lightGray
        segmentedControlView.layer.cornerRadius = 8
        addSubview(segmentedControlView)

        activePlanButton = UIButton(type: .system)
        activePlanButton.setTitle("Active Plan", for: .normal)
        activePlanButton.backgroundColor = .systemBlue
        activePlanButton.setTitleColor(.white, for: .normal)
        activePlanButton.layer.cornerRadius = 8
        activePlanButton.addTarget(self, action: #selector(activePlanButtonTapped), for: .touchUpInside)
        segmentedControlView.addSubview(activePlanButton)

        otherPlansButton = UIButton(type: .system)
        otherPlansButton.setTitle("All Plans", for: .normal)
        otherPlansButton.backgroundColor = .clear
        otherPlansButton.setTitleColor(.systemBlue, for: .normal)
        otherPlansButton.layer.cornerRadius = 8
        otherPlansButton.addTarget(self, action: #selector(otherPlansButtonTapped), for: .touchUpInside)
        segmentedControlView.addSubview(otherPlansButton)

        segmentedControlView.translatesAutoresizingMaskIntoConstraints = false
        activePlanButton.translatesAutoresizingMaskIntoConstraints = false
        otherPlansButton.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupTableViewTravelPlans() {
        tableViewTravelPlans = UITableView()
        tableViewTravelPlans.register(TravelPlanTableViewCell.self, forCellReuseIdentifier: Configs.tableViewTravelPlansID)
        tableViewTravelPlans.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(tableViewTravelPlans)
    }

    func setupButtonAddTravelPlan() {
        buttonAddTravelPlan = UIButton(type: .system)
        buttonAddTravelPlan.setTitle("Add Travel Plan", for: .normal)
        buttonAddTravelPlan.backgroundColor = .systemBlue
        buttonAddTravelPlan.setTitleColor(.white, for: .normal)
        buttonAddTravelPlan.layer.cornerRadius = 8
        buttonAddTravelPlan.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(buttonAddTravelPlan)
    }

    func setupActivePlanDetailView() {
        activePlanDetailView = UIView()
        activePlanDetailView.isHidden = true
        activePlanDetailView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activePlanDetailView)

        activePlanTitleLabel = UILabel()
        activePlanTitleLabel.font = .boldSystemFont(ofSize: 18)
        activePlanTitleLabel.textAlignment = .center
        activePlanTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        activePlanDetailView.addSubview(activePlanTitleLabel)

        activePlanDateLabel = UILabel()
        activePlanDateLabel.font = .systemFont(ofSize: 14)
        activePlanDateLabel.textAlignment = .center
        activePlanDateLabel.translatesAutoresizingMaskIntoConstraints = false
        activePlanDetailView.addSubview(activePlanDateLabel)

        activePlanLocationLabel = UILabel()
        activePlanLocationLabel.font = .systemFont(ofSize: 14)
        activePlanLocationLabel.textAlignment = .center
        activePlanLocationLabel.translatesAutoresizingMaskIntoConstraints = false
        activePlanDetailView.addSubview(activePlanLocationLabel)
        
        activePlanParticipantIdsLabel = UILabel()
        activePlanParticipantIdsLabel.font = .systemFont(ofSize: 14)
        activePlanParticipantIdsLabel.textAlignment = .center
        activePlanParticipantIdsLabel.numberOfLines = 0 // Allow multiple lines
        activePlanParticipantIdsLabel.translatesAutoresizingMaskIntoConstraints = false
        activePlanDetailView.addSubview(activePlanParticipantIdsLabel)
        
        activePlanDescriptionLabel = UILabel()
        activePlanDescriptionLabel.font = .systemFont(ofSize: 14)
        activePlanDescriptionLabel.textAlignment = .center
        activePlanDescriptionLabel.textColor = .systemGray
        activePlanDescriptionLabel.numberOfLines = 0 // Allow multiple lines
        activePlanDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        activePlanDetailView.addSubview(activePlanDescriptionLabel)
    }
    // MARK: - Button Actions

    @objc func activePlanButtonTapped() {
        delegate?.didTapActivePlanButton()
    }

    @objc func otherPlansButtonTapped() {
        delegate?.didTapOtherPlansButton()
    }

    // MARK: - Layout Constraints

    func initConstraints() {
        NSLayoutConstraint.activate([
            labelText.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 8),
            labelText.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            labelText.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),

            segmentedControlView.topAnchor.constraint(equalTo: labelText.bottomAnchor, constant: 16),
            segmentedControlView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            segmentedControlView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            segmentedControlView.heightAnchor.constraint(equalToConstant: 44),

            activePlanButton.leadingAnchor.constraint(equalTo: segmentedControlView.leadingAnchor),
            activePlanButton.topAnchor.constraint(equalTo: segmentedControlView.topAnchor),
            activePlanButton.bottomAnchor.constraint(equalTo: segmentedControlView.bottomAnchor),
            activePlanButton.widthAnchor.constraint(equalTo: segmentedControlView.widthAnchor, multiplier: 0.5),

            otherPlansButton.trailingAnchor.constraint(equalTo: segmentedControlView.trailingAnchor),
            otherPlansButton.topAnchor.constraint(equalTo: segmentedControlView.topAnchor),
            otherPlansButton.bottomAnchor.constraint(equalTo: segmentedControlView.bottomAnchor),
            otherPlansButton.widthAnchor.constraint(equalTo: segmentedControlView.widthAnchor, multiplier: 0.5),

            activePlanDetailView.topAnchor.constraint(equalTo: segmentedControlView.bottomAnchor, constant: 16),
            activePlanDetailView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            activePlanDetailView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),

            activePlanTitleLabel.topAnchor.constraint(equalTo: activePlanDetailView.topAnchor, constant: 16),
            activePlanTitleLabel.leadingAnchor.constraint(equalTo: activePlanDetailView.leadingAnchor),
            activePlanTitleLabel.trailingAnchor.constraint(equalTo: activePlanDetailView.trailingAnchor),

            activePlanDateLabel.topAnchor.constraint(equalTo: activePlanTitleLabel.bottomAnchor, constant: 8),
            activePlanDateLabel.leadingAnchor.constraint(equalTo: activePlanDetailView.leadingAnchor),
            activePlanDateLabel.trailingAnchor.constraint(equalTo: activePlanDetailView.trailingAnchor),

            activePlanLocationLabel.topAnchor.constraint(equalTo: activePlanDateLabel.bottomAnchor, constant: 8),
            activePlanLocationLabel.leadingAnchor.constraint(equalTo: activePlanDetailView.leadingAnchor),
            activePlanLocationLabel.trailingAnchor.constraint(equalTo: activePlanDetailView.trailingAnchor),
            
            activePlanParticipantIdsLabel.topAnchor.constraint(equalTo: activePlanLocationLabel.bottomAnchor, constant: 8),
            activePlanParticipantIdsLabel.leadingAnchor.constraint(equalTo: activePlanDetailView.leadingAnchor),
            activePlanParticipantIdsLabel.trailingAnchor.constraint(equalTo: activePlanDetailView.trailingAnchor),
            
            activePlanDescriptionLabel.topAnchor.constraint(equalTo: activePlanParticipantIdsLabel.bottomAnchor, constant: 16),
            activePlanDescriptionLabel.leadingAnchor.constraint(equalTo: activePlanDetailView.leadingAnchor),
            activePlanDescriptionLabel.trailingAnchor.constraint(equalTo: activePlanDetailView.trailingAnchor),
            activePlanDescriptionLabel.bottomAnchor.constraint(equalTo: activePlanDetailView.bottomAnchor, constant: -16),

            tableViewTravelPlans.topAnchor.constraint(equalTo: segmentedControlView.bottomAnchor, constant: 16),
            tableViewTravelPlans.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tableViewTravelPlans.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tableViewTravelPlans.bottomAnchor.constraint(equalTo: buttonAddTravelPlan.topAnchor, constant: -16),

            buttonAddTravelPlan.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            buttonAddTravelPlan.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            buttonAddTravelPlan.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            buttonAddTravelPlan.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}
