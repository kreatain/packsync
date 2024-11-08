//
//  SignUpFirebaseManager.swift
//  app12
//
//  Created by Xi Jia on 11/5/24.
//

import Foundation
import FirebaseAuth

extension SignUpViewController{
    
    func signUpNewAccount(){
        
        //MARK: display the progress indicator...
        showActivityIndicator()
        
        //MARK: create a Firebase user with email and password...
        // read the text fields to unwrap name, email, and password.
        if let name = signUpView.nameTextField.text,
           let email = signUpView.emailTextField.text,
           let password = signUpView.passwordTextField.text{
            
            //Validations....
            
            // call Auth.auth().createUser(withEmail:...) to send a request to the Firebase Authentication service to create a user with email and password.
            Auth.auth().createUser(withEmail: email, password: password, completion: {result, error in
                // check if the error is nil, meaning if there is no error.
                if error == nil{
                    //  If there is no error, we decide that the response was successful, and the user is created.
                    
                    //MARK: the user creation is successful...
                    
                    // Please note we cannot set the profile data in a FirebaseAuth account while creating the account. It can create just an account with the email and password. Then we have to update the profile with the name provided by the user in setNameOfTheUserInFirebaseAuth() method.
                    self.setNameOfTheUserInFirebaseAuth(name: name)
                    
                }else{
                    //MARK: there is a error creating the user...
                    print(error as Any)
                }
            })
        }
    }
    
    //MARK: We set the name of the user after we create the account...
    func setNameOfTheUserInFirebaseAuth(name: String){
        // create a change request for the current FirebaseAuth user.
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        //  set the intended name of the user in the change request.
        changeRequest?.displayName = name
        // commit the changes with a request.
        changeRequest?.commitChanges(completion: {(error) in
            // If there is no error, the response returns a nil error. So, here we can certainly say that the profile has been updated.
            if error == nil{
                //MARK: the profile update is successful...
                
                //MARK: hide the progress indicator...
                self.hideActivityIndicator()
                
                // close the register screen and return to the main screen
                self.navigationController?.popViewController(animated: true)
                
            }else{
                //MARK: there was an error updating the profile...
                print("Error occured: \(String(describing: error))")
            }
        })
    }
}
