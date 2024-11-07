//
//  TravelListView.swift
//  Packsync
//
//  Created by 许多 on 10/24/24.
//



import UIKit

class TravelListView: UIView {
    
    let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to TravelCrew!"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let getStartedButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Get Started", for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var floatingButtonLogin: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        setupFloatingButtonLoginl()
        setupView()
        initConstraints()
    }
    
    private func setupView() {
        backgroundColor = .white
        addSubview(welcomeLabel)
        addSubview(getStartedButton)
        
        NSLayoutConstraint.activate([
            // Welcome Label Constraints
            welcomeLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 40),
            welcomeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            // Get Started Button Constraints
            getStartedButton.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 20),
            getStartedButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            getStartedButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
    
    //MARK: initializing the UI elements...
    func setupFloatingButtonLoginl(){
        floatingButtonLogin = UIButton(type: .system)
        floatingButtonLogin.setTitle("", for: .normal)
        floatingButtonLogin.setImage(UIImage(systemName: "person.crop.circle.fill.badge.plus")?.withRenderingMode(.alwaysOriginal), for: .normal)
        floatingButtonLogin.contentHorizontalAlignment = .fill
        floatingButtonLogin.contentVerticalAlignment = .fill
        floatingButtonLogin.imageView?.contentMode = .scaleAspectFit
        floatingButtonLogin.layer.cornerRadius = 16
        floatingButtonLogin.imageView?.layer.shadowOffset = .zero
        floatingButtonLogin.imageView?.layer.shadowRadius = 0.8
        floatingButtonLogin.imageView?.layer.shadowOpacity = 0.7
        floatingButtonLogin.imageView?.clipsToBounds = true
        floatingButtonLogin.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(floatingButtonLogin)
    }
    
    //MARK: setting up constraints...
    func initConstraints(){
        NSLayoutConstraint.activate([
            floatingButtonLogin.widthAnchor.constraint(equalToConstant: 48),
            floatingButtonLogin.heightAnchor.constraint(equalToConstant: 48),
            floatingButtonLogin.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            floatingButtonLogin.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
