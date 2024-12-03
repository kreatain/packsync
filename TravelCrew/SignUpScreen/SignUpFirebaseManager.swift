//
//  SignUpFirebaseManager.swift
//  app12
//
//  Created by Xi Jia on 11/5/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

extension SignUpViewController {
    
    func signUpNewAccount() {
        // Show activity indicator
        showActivityIndicator()
        
        // Validate user inputs
        guard let name = signUpView.nameTextField.text, !name.isEmpty,
              let email = signUpView.emailTextField.text, !email.isEmpty,
              let password = signUpView.passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "All fields are required.")
            hideActivityIndicator()
            return
        }
        
        // Validate email format
        if !isValidEmail(email) {
            showAlert(title: "Invalid Email", message: "Please enter a valid email address.")
            hideActivityIndicator()
            return
        }
        
        // Validate password strength
        if password.count < 6 {
            showAlert(title: "Weak Password", message: "Password must be at least 6 characters long.")
            hideActivityIndicator()
            return
        }
        
        // Check if the email already exists
        Auth.auth().fetchSignInMethods(forEmail: email) { signInMethods, error in
            if let error = error {
                print("Error checking email: \(error.localizedDescription)")
                self.showAlert(title: "Error", message: "Unable to verify email at this time. Please try again.")
                self.hideActivityIndicator()
                return
            }
            
            if let signInMethods = signInMethods, !signInMethods.isEmpty {
                // Email already in use
                self.showAlert(title: "Email Exists", message: "This email is already registered. Please use a different email or sign in.")
                self.hideActivityIndicator()
            } else {
                // Proceed with user registration
                self.createFirebaseUser(name: name, email: email, password: password)
            }
        }
    }
    
    private func createFirebaseUser(name: String, email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
                self.showAlert(title: "Error", message: error.localizedDescription)
                self.hideActivityIndicator()
                return
            }
            
            guard let authResult = result else {
                self.showAlert(title: "Error", message: "Unexpected error during account creation. Please try again.")
                self.hideActivityIndicator()
                return
            }
            
            // Set display name in Firebase Auth
            self.setNameOfTheUserInFirebaseAuth(name: name)
            
            // Create a User model instance
            let user = User(
                id: authResult.user.uid,
                email: email,
                password: password, // Avoid storing raw passwords in production; store hashed/encrypted versions
                displayName: name,
                profilePicURL: nil
            )
            
            // Save user data to Firestore
            self.saveUserToFirestore(user: user)
        }
    }
    
    // Set the display name for the FirebaseAuth user profile
    func setNameOfTheUserInFirebaseAuth(name: String) {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = name
        changeRequest?.commitChanges { error in
            if let error = error {
                print("Error updating profile: \(error.localizedDescription)")
            } else {
                print("User profile updated successfully")
            }
            self.hideActivityIndicator()
        }
    }
    
    // Save the User model to Firestore
    func saveUserToFirestore(user: User) {
        let db = Firestore.firestore()
        do {
            try db.collection("users").document(user.id).setData(from: user) { error in
                if let error = error {
                    print("Error saving user to Firestore: \(error.localizedDescription)")
                    self.showAlert(title: "Error", message: "Failed to save user data. Please try again.")
                } else {
                    print("User saved successfully to Firestore")
                    self.showAlert(title: "Success", message: "Your account has been created successfully!") {
                        // Navigate back to login screen or dismiss
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                self.hideActivityIndicator()
            }
        } catch let error {
            print("Error encoding user data: \(error.localizedDescription)")
            self.showAlert(title: "Error", message: "Failed to process user data. Please try again.")
            self.hideActivityIndicator()
        }
    }
    
    // Validate email format
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // Show alert to user
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

