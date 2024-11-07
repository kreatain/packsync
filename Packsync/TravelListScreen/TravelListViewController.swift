//
//  TravelListViewController.swift
//  Packsync
//
//  Created by 许多 on 10/24/24.
//
import UIKit

class TravelListViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Travels"
        view.backgroundColor = .white
        
        // Add any additional navigation bar items if needed
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
    }
    
    @objc func addTapped() {
        // Handle add button tap
    }
}
