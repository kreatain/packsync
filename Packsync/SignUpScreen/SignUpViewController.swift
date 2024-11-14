//
//  SignUpViewController.swift
//  Packsync
//
//  Created by Xi Jia/Jessica Li on 11/8/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase // Import FirebaseDatabase to interact with Realtime Database


class SignUpViewController: UIViewController {

    let signUpView = SignUpView()
    let childProgressView = ProgressSpinnerViewController()
    
    override func loadView() {
        view = signUpView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        signUpView.signUpButton.addTarget(self, action: #selector(onRegisterTapped), for: .touchUpInside)
        title = "SignUp"
    }
    
    @objc func onRegisterTapped(){
        //MARK: creating a new user on Firebase...
        signUpNewAccount()
    }
    
    
    
}
