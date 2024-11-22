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
        
        detailView.buttonPackingList.addTarget(self, action: #selector(packingListButtonTapped), for: .touchUpInside)
        detailView.buttonInviteFriend.addTarget(self, action: #selector(inviteFriendButtonTapped), for: .touchUpInside)
        detailView.buttonSpending.addTarget(self, action: #selector(spendingButtonTapped), for: .touchUpInside)
        detailView.buttonBillboard.addTarget(self, action: #selector(billboardButtonTapped), for: .touchUpInside)

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
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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
        guard let t = travel else {
            print("No travel plan available for inviteFriendButtonTapped")
            return
        }
        let inviteFriendVC = InviteFriendViewController(travelID: t.id, travelTitle: t.travelTitle)
        navigationController?.pushViewController(inviteFriendVC, animated: true)
    }
    
    @objc func spendingButtonTapped() {
        guard let travel = travel else {
            print("No travel plan available")
            return
        }

        let spendingVC = SpendingViewController(travelID: travel.id) // Pass the travel ID here
        navigationController?.pushViewController(spendingVC, animated: true)
    }
    
    
    @objc func billboardButtonTapped() {
        guard let travelId = travel?.id else {
            print("No travel ID available to pass to BillboardViewController.")
            return
        }
        
        let billboardVC = BillboardViewController()
        billboardVC.travelId = travelId 
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
