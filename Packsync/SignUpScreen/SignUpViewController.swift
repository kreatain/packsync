//
//  SignUpViewController.swift
//  Packsync
//
//  Created by 许多 on 10/24/24.
//
import UIKit
class SignUpViewController: UIViewController {
    private let signUpView = SignUpView()
    
    override func loadView() {
        view = signUpView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sign Up"
        setupActions()
    }
    
    private func setupActions() {
        signUpView.signUpButton.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
    }
    
    @objc func handleSignUp() {
        guard let name = signUpView.nameTextField.text, !name.isEmpty,
              let email = signUpView.emailTextField.text, !email.isEmpty,
              let password = signUpView.passwordTextField.text, !password.isEmpty else {
            showAlert("Missing Information", "Please enter your name, email, and password.")
            return
        }
        
    }
    
    private func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func navigateToProfile() {
        let profileVC = ProfileViewController()
        navigationController?.pushViewController(profileVC, animated: true)
    }
}
