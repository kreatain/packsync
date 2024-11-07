//
//  AddANewTraverlViewController.swift
//  Packsync
//
//  Created by Xi Jia on 11/7/24.
//

import UIKit

class AddANewTraverlViewController: UIViewController {
    
    let addANewTraverlView = AddANewTraverlView()
    
    override func loadView(){
        view = addANewTraverlView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add a new travel plan"
        
        

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
