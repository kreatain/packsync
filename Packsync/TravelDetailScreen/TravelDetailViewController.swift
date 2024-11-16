//
//  TravelDetailViewController.swift
//  Packsync
//
//  Created by Xi Jia on 11/8/24.
//


import UIKit
import FirebaseFirestore

class TravelDetailViewController: UIViewController {
    var travel: Travel?
    let detailView = TravelDetailView()
    
    override func loadView() {
        view = detailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Travel Plan Details"
        
        if let travel = travel {
            detailView.configure(with: travel)
        }
        
        // Add an edit button to the navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTravelPlan))
        
        detailView.buttonSetAsActivePlan.addTarget(self, action: #selector(setAsActivePlanButtonTapped), for: .touchUpInside)
        detailView.buttonPackingList.addTarget(self, action: #selector(packingListButtonTapped), for: .touchUpInside)
        detailView.buttonInviteFriend.addTarget(self, action: #selector(inviteFriendButtonTapped), for: .touchUpInside)
        detailView.buttonSpending.addTarget(self, action: #selector(spendingButtonTapped), for: .touchUpInside)
        detailView.buttonBillboard.addTarget(self, action: #selector(billboardButtonTapped), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(activeTravelPlanChanged), name: .activeTravelPlanChanged, object: nil)
        
        updateButtonState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateButtonState()
    }
    
    private func updateButtonState() {
        if let travel = travel {
            let isActive = TravelPlanManager.shared.activeTravelPlan?.id == travel.id
            detailView.updateSetAsActivePlanButton(isActive: isActive)
        }
    }
    
    @objc func editTravelPlan() {
        guard let travel = travel else {
            print("No travel plan to edit")
            return
        }
        let editVC = EditTravelDetailViewController()
        editVC.travel = travel
        editVC.delegate = self
        let navController = UINavigationController(rootViewController: editVC)
        present(navController, animated: true, completion: nil)
    }
    
    @objc func setAsActivePlanButtonTapped() {
        guard let travel = travel else {
            print("No travel plan available")
            return
        }
        
        let travelPlanManager = TravelPlanManager.shared
        
        if travelPlanManager.activeTravelPlan?.id == travel.id {
            travelPlanManager.clearActiveTravelPlan()
            showAlert(title: "Active Plan Unset", message: "This travel plan is no longer the active plan.")
        } else {
            travelPlanManager.setActiveTravelPlan(travel)
            showAlert(title: "Active Plan Set", message: "This travel plan has been set as the active plan.")
        }
        
        updateButtonState()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Button frame: \(detailView.buttonSetAsActivePlan.frame)")
        print("Button isUserInteractionEnabled: \(detailView.buttonSetAsActivePlan.isUserInteractionEnabled)")
        print("Button isHidden: \(detailView.buttonSetAsActivePlan.isHidden)")
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func activeTravelPlanChanged() {
        print("Active travel plan changed notification received")
        if let travel = travel {
            detailView.configure(with: travel)
            updateButtonState()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func packingListButtonTapped() {
        guard let travel = travel else {
            print("No travel plan available")
            return
        }
        let packingListVC = PackingListViewController()
        packingListVC.travel = self.travel
        navigationController?.pushViewController(packingListVC, animated: true)
    }
    
    @objc func inviteFriendButtonTapped() {
        let inviteFriendVC = InviteFriendViewController()
        navigationController?.pushViewController(inviteFriendVC, animated: true)
    }
    
    @objc func spendingButtonTapped() {
        let spendingVC = SpendingViewController()
        navigationController?.pushViewController(spendingVC, animated: true)
    }
    
    @objc func billboardButtonTapped() {
        let billboardVC = BillboardViewController()
        navigationController?.pushViewController(billboardVC, animated: true)
    }
}

// Ensure this conforms to EditTravelDetailDelegate
extension TravelDetailViewController: EditTravelDetailDelegate {
    func didUpdateTravel(_ travel: Travel) {
        self.travel = travel
        detailView.configure(with: travel)
    }
    
    func didDeleteTravel(_ travel: Travel) {
        navigationController?.popViewController(animated: true)
    }
}
