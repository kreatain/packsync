//
//  TravelListView.swift
//  Packsync
//
//  Created by 许多 on 10/24/24.
//



import UIKit

class TravelListView: UIView {
    
    var floatingButtonAddANewTravel: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white

        initConstraints()
    }
    
    //MARK: initializing the UI elements...
    
    
    //MARK: setting up constraints...
    func initConstraints(){
        NSLayoutConstraint.activate([
            
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
