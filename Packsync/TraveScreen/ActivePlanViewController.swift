//
//  ActivePlanViewController.swift
//  Packsync
//
//  Created by 许多 on 11/12/24.
//

import UIKit

class ActivePlanViewController: UIViewController {

    private var activeTravelPlan: Travel? {
        return TravelPlanManager.shared.activeTravelPlan
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshUI), name: .activeTravelPlanChanged, object: nil)
    }

    func setupUI() {
        guard let plan = activeTravelPlan else { return }
        let titleLabel = UILabel()
        titleLabel.text = "Active Plan: \(plan.travelTitle)"
        view.addSubview(titleLabel)
        // Additional UI setup for displaying plan details
    }

    @objc func refreshUI() {
        setupUI()
    }
}
