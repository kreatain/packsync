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
        
        // navigate to the packing list screen
        detailView.buttonPackingList.addTarget(self, action: #selector(packingListButtonTapped), for: .touchUpInside)
        
        detailView.buttonInviteFriend.addTarget(self, action: #selector(inviteFriendButtonTapped), for: .touchUpInside)
    }
    
    @objc func editTravelPlan() {
        guard let travel = travel else {
            print("No travel plan to edit")
            return
        }
        let editVC = EditTravelDetailViewController()
        editVC.travel = travel
        editVC.delegate = self // Now conforms to EditTravelDetailDelegate
        let navController = UINavigationController(rootViewController: editVC)
        present(navController, animated: true, completion: nil)
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
