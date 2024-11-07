//
//  LoginViewController.swift
//  Packsync
//
//  Created by 许多 on 10/24/24.
//
//
import UIKit

class LoginViewController: UIViewController {
    private let loginView = LoginView()

    override func loadView() {
        view = loginView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        setupActions()
    }
    
    private func setupActions() {
        // Update to match button names in LoginView
        loginView.signInButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        loginView.signUpLinkButton.addTarget(self, action: #selector(handleSignup), for: .touchUpInside)
    }
    
    @objc func handleLogin() {
        guard let email = loginView.emailTextField.text, !email.isEmpty,
              let password = loginView.passwordTextField.text, !password.isEmpty else {
            showAlert("Missing Information", "Please enter both email and password.")
            return
        }
        
    }
    
    @objc func handleSignup() {
        let signUpVC = SignUpViewController()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    private func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
   private func navigateToProfile() {
        let homeVC = HomeViewController()
        navigationController?.pushViewController(homeVC, animated: true)
    }
}
