//
//  SignUpProgressIndicatorManager.swift
//  app12
//
//  Created by Xi Jia on 11/5/24.
//

import Foundation

extension SignUpViewController:ProgressSpinnerDelegate{
    func showActivityIndicator(){
        // add the indicator as a child view of the current view
        addChild(childProgressView)
        view.addSubview(childProgressView.view)
        // didMove(toParent: self) method to attach and display the indicator on top of the current view.
        childProgressView.didMove(toParent: self)
    }
    
    func hideActivityIndicator(){
        //  detach the indicator on line 18.
        childProgressView.willMove(toParent: nil)
        // remove the indicator views from their parent
        childProgressView.view.removeFromSuperview()
        childProgressView.removeFromParent()
    }
}
