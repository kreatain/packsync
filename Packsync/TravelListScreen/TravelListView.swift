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
        
        setupFloatingButtonAddNewTravel()
        initConstraints()
    }
    
    //MARK: initializing the UI elements...

    func setupFloatingButtonAddNewTravel() {
        floatingButtonAddANewTravel = UIButton(type: .system)
        floatingButtonAddANewTravel.setTitle("", for: .normal)

        let config = UIImage.SymbolConfiguration(textStyle: .title2)
        let airplaneImage = UIImage(systemName: "airplane.circle.fill", withConfiguration: config)?.withTintColor(.blue, renderingMode: .alwaysOriginal)

        floatingButtonAddANewTravel.setImage(airplaneImage, for: .normal)
        
        // Rest of your setup code remains the same
        floatingButtonAddANewTravel.contentHorizontalAlignment = .fill
        floatingButtonAddANewTravel.contentVerticalAlignment = .fill
        floatingButtonAddANewTravel.imageView?.contentMode = .scaleAspectFit
        floatingButtonAddANewTravel.layer.cornerRadius = 16
        floatingButtonAddANewTravel.imageView?.layer.shadowOffset = .zero
        floatingButtonAddANewTravel.imageView?.layer.shadowRadius = 0.8
        floatingButtonAddANewTravel.imageView?.layer.shadowOpacity = 0.7
        floatingButtonAddANewTravel.imageView?.clipsToBounds = true
        floatingButtonAddANewTravel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(floatingButtonAddANewTravel)
    }
    
    
    //MARK: setting up constraints...
    func initConstraints(){
        NSLayoutConstraint.activate([
            
            floatingButtonAddANewTravel.widthAnchor.constraint(equalToConstant: 48),
            floatingButtonAddANewTravel.heightAnchor.constraint(equalToConstant: 48),
            floatingButtonAddANewTravel.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            floatingButtonAddANewTravel.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
