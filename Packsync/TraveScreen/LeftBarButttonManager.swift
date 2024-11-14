//
//  LeftBarButttonManager.swift
//  Packsync
//
//  Created by Xi Jia on 11/7/24.
//

import UIKit
import FirebaseAuth

extension TravelViewController {
    func setupLeftBarButton(isLoggedin: Bool){
        if isLoggedin{
            //MARK: user is logged in...
            let barText = UIBarButtonItem(
                title: "Logout",
                style: .plain,
                target: self,
                action: #selector(onLogOutBarButtonTapped)
            )
            navigationItem.leftBarButtonItems = [barText]
            
        }else{
            //MARK: not logged in...
            let barText = UIBarButtonItem(
                title: "Sign in",
                style: .plain,
                target: self,
                action: #selector(onSignInBarButtonTapped)
            )
            navigationItem.leftBarButtonItems = [barText]
        }
    }
    
    @objc func onSignInBarButtonTapped(){
        // set up the title and message of the alert controller. The text fields are added to an array of text fields inside the alert controller.
        let signInAlert = UIAlertController(
            title: "Sign In / Register",
            message: "Please sign in to continue.",
            preferredStyle: .alert)
        
        //MARK: setting up email textField in the alert...
        signInAlert.addTextField{ textField in
            textField.placeholder = "Enter email"
            textField.contentMode = .center
            textField.keyboardType = .emailAddress
        }
        
        //MARK: setting up password textField in the alert...
        signInAlert.addTextField{ textField in
            textField.placeholder = "Enter password"
            textField.contentMode = .center
            textField.isSecureTextEntry = true
        }
        
        //MARK: Sign In Action...
        let signInAction = UIAlertAction(title: "Sign In", style: .default, handler: {(_) in
            if let email = signInAlert.textFields![0].text,
               let password = signInAlert.textFields![1].text{
                //MARK: sign-in logic for Firebase...
                self.signInToFirebase(email: email, password: password)
            }
        })
        
        //MARK: SignUp Action...
        let signUpAction = UIAlertAction(title: "SignUp", style: .default, handler: {(_) in
            //MARK: logic to open the register screen...
            let signUpViewController = SignUpViewController()
            self.navigationController?.pushViewController(signUpViewController, animated: true)
        })
        
        //MARK: action buttons, add the actions to the alert controller
        signInAlert.addAction(signUpAction)
        signInAlert.addAction(signInAction)

        // present the alert controller. In the completion closure, we write logic to handle if the user taps outside the alert.
        self.present(signInAlert, animated: true, completion: {() in
            // to hide the alerton tap outside, add a Gesture Recognizer on the superview (the screen which popped this alert) of the alert controller.
            signInAlert.view.superview?.isUserInteractionEnabled = true
            signInAlert.view.superview?.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(self.onTapOutsideAlert))
            )
        })
    }
    
    // If the user taps on the super view, the alert gets dismissed.
    @objc func onTapOutsideAlert(){
        self.dismiss(animated: true)
    }
    
    @objc func onLogOutBarButtonTapped(){
        let logoutAlert = UIAlertController(title: "Logging out!", message: "Are you sure want to log out?",
            preferredStyle: .actionSheet)
        logoutAlert.addAction(UIAlertAction(title: "Yes, log out!", style: .default, handler: { [weak self] (_) in
            do {
                try Auth.auth().signOut()
                // The auth state listener in TravelViewController will handle UI updates
            } catch {
                print("Error occured during logout: \(error.localizedDescription)")
                self?.showAlert(title: "Logout Error", message: "An error occurred while logging out. Please try again.")
            }
        }))
        logoutAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(logoutAlert, animated: true)
    }
    
    func signInToFirebase(email: String, password: String){
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            if let error = error {
                // Show alert for authentication error
                self?.showAlert(title: "Sign In Error", message: error.localizedDescription)
            } else {
                // Authentication successful, UI will be updated by the auth state listener
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

