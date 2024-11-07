//
//  ProfileViewController.swift
//  Packsync
//
//  Created by 许多 on 10/24/24.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Profile"
        view.backgroundColor = .white
        
        // Add any additional navigation bar items if needed
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
    }
    
    @objc func addTapped() {
        // Handle add button tap
    }

}
