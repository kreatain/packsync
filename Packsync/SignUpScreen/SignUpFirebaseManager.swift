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
        
        // Unwrap name, email, and password from text fields
        if let name = signUpView.nameTextField.text,
           let email = signUpView.emailTextField.text,
           let password = signUpView.passwordTextField.text {
            
            // Call Firebase Auth to create a new user with email and password
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    // Handle error in user creation
                    print("Error creating user: \(error.localizedDescription)")
                    self.hideActivityIndicator()
                } else if let authResult = result {
                    // Successful user creation
                    
                    // Set display name in FirebaseAuth
                    self.setNameOfTheUserInFirebaseAuth(name: name)
                    
                    // Create a new User model instance
                    let user = User(
                        id: authResult.user.uid,
                        email: email,
                        password: password, // Avoid storing raw passwords in production; store only a hash or encrypted version
                        displayName: name,
                        profilePicURL: nil
                    )
                    
                    // Save user to Firestore
                    self.saveUserToFirestore(user: user)
                }
            }
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
                } else {
                    print("User saved successfully to Firestore")
                    // Dismiss registration screen and navigate back
                    self.navigationController?.popViewController(animated: true)
                }
                self.hideActivityIndicator()
            }
        } catch let error {
            print("Error encoding user data: \(error.localizedDescription)")
            self.hideActivityIndicator()
        }
    }
}
