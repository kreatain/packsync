//
//  TravelListViewController.swift
//  Packsync
//
//  Created by 许多 on 10/24/24.
//
import UIKit

class TravelListViewController: UIViewController {
    
    let travelListView = TravelListView()
    
    override func loadView() {
        view = travelListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Travels"
        view.backgroundColor = .white
        
        // Add A New Traver button navigation to the AddANewTraverl Screen
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTravelButtonTapped))
    }
    
    @objc func addTravelButtonTapped() {
        let addTravelViewController = AddANewTraverlViewController()
        navigationController?.pushViewController(addTravelViewController, animated: true)
    }

}
