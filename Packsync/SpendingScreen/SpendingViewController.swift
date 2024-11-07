//
//  SpendingViewController.swift
//  Packsync
//
//  Created by Xi Jia on 11/6/24.
//

import UIKit

class SpendingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Spending"
        view.backgroundColor = .white
        
        // Add any additional navigation bar items if needed
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
    }
    
    @objc func addTapped() {
        // Handle add button tap
    }

}
