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
        
        travelListView.floatingButtonAddANewTravel.addTarget(self, action: #selector(addTravelButtonTapped), for: .touchUpInside)
        
        // Add any additional navigation bar items if needed
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
    }
    
    @objc func addTravelButtonTapped() {
        let addTravelViewController = AddANewTraverlViewController()
        navigationController?.pushViewController(addTravelViewController, animated: true)
    }
    @objc func addTapped() {
        // Handle add button tap
    }
}
