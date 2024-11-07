//
//  AddANewTraverlView.swift
//  Packsync
//
//  Created by Xi Jia on 11/7/24.
//

import UIKit

class AddANewTraverlView: UIView {
    
    var scrollView: UIScrollView!
    var contentView: UIView!
    
    var labelTravelTitle: UILabel!
    var labelTravelStartDate: UILabel!
    var labelTravelEndDate: UILabel!
    var labelTravelCountryAndCity: UILabel!
    
    var textFieldTravelTitle: UITextField!
    var textFieldTravelStartDate: UITextField!
    var textFieldTravelEndDate: UITextField!
    var textFieldCountryAndCity: UITextField!
    var buttonAdd: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        setupScrollView()
        setupContentView()
        setupLabelTravelTitle()
        setupLabelTravelStartDate()
        setupLabelTravelEndDate()
        setupLabelCountryAndCity()
        setuptextFieldTravelTitle()
        setuptextFieldTravelStartDate()
        setuptextFieldTravelEndDate()
        setupTextFieldCountryAndCity()
        setupbuttonRegister()
        
        initConstraints()
    }
    
    func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        self.addSubview(scrollView)
    }
    
    func setupContentView() {
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
    }
    
    func setupLabelTravelTitle() {
        labelTravelTitle = UILabel()
        labelTravelTitle.text = "Travel Title"
        labelTravelTitle.font = .systemFont(ofSize: 16, weight: .medium)
        labelTravelTitle.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(labelTravelTitle)
    }
    
    func setupLabelTravelStartDate() {
        labelTravelStartDate = UILabel()
        labelTravelStartDate.text = "Travel Start Date"
        labelTravelStartDate.font = .systemFont(ofSize: 16, weight: .medium)
        labelTravelStartDate.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(labelTravelStartDate)
    }
    
    func setupLabelTravelEndDate() {
        labelTravelEndDate = UILabel()
        labelTravelEndDate.text = "Travel End Date"
        labelTravelEndDate.font = .systemFont(ofSize: 16, weight: .medium)
        labelTravelEndDate.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(labelTravelEndDate)
    }
    
    func setupLabelCountryAndCity() {
        labelTravelCountryAndCity = UILabel()
        labelTravelCountryAndCity.text = "Country, City"
        labelTravelCountryAndCity.font = .systemFont(ofSize: 16, weight: .medium)
        labelTravelCountryAndCity.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(labelTravelCountryAndCity)
    }
    
    func setuptextFieldTravelTitle() {
        textFieldTravelTitle = UITextField()
        textFieldTravelTitle.placeholder = "Put a title of the travel"
        textFieldTravelTitle.keyboardType = .default
        textFieldTravelTitle.borderStyle = .roundedRect
        textFieldTravelTitle.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textFieldTravelTitle)
    }
    
    func setuptextFieldTravelStartDate() {
        textFieldTravelStartDate = UITextField()
        textFieldTravelStartDate.placeholder = "Travel start date"
        textFieldTravelStartDate.keyboardType = .default
        textFieldTravelStartDate.borderStyle = .roundedRect
        textFieldTravelStartDate.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textFieldTravelStartDate)
    }
    
    func setuptextFieldTravelEndDate() {
        textFieldTravelEndDate = UITextField()
        textFieldTravelEndDate.placeholder = "Travel end date"
        textFieldTravelEndDate.borderStyle = .roundedRect
        textFieldTravelEndDate.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textFieldTravelEndDate)
    }
    
    func setupTextFieldCountryAndCity() {
        textFieldCountryAndCity = UITextField()
        textFieldCountryAndCity.placeholder = "Travel country and city"
        textFieldCountryAndCity.borderStyle = .roundedRect
        textFieldCountryAndCity.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textFieldCountryAndCity)
    }
    
    func setupbuttonRegister() {
        buttonAdd = UIButton(type: .system)
        buttonAdd.setTitle("Add", for: .normal)
        buttonAdd.titleLabel?.font = .boldSystemFont(ofSize: 16)
        buttonAdd.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(buttonAdd)
    }
    
    func initConstraints() {
        NSLayoutConstraint.activate([
            // Scroll View Constraints
            scrollView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            
            // Content View Constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // UI Elements Constraints
            labelTravelTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            labelTravelTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            textFieldTravelTitle.topAnchor.constraint(equalTo: labelTravelTitle.bottomAnchor, constant: 8),
            textFieldTravelTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            textFieldTravelTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            labelTravelStartDate.topAnchor.constraint(equalTo: textFieldTravelTitle.bottomAnchor, constant: 16),
            labelTravelStartDate.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            textFieldTravelStartDate.topAnchor.constraint(equalTo: labelTravelStartDate.bottomAnchor, constant: 8),
            textFieldTravelStartDate.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            textFieldTravelStartDate.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            labelTravelEndDate.topAnchor.constraint(equalTo: textFieldTravelStartDate.bottomAnchor, constant: 16),
            labelTravelEndDate.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            textFieldTravelEndDate.topAnchor.constraint(equalTo: labelTravelEndDate.bottomAnchor, constant: 8),
            textFieldTravelEndDate.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            textFieldTravelEndDate.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            labelTravelCountryAndCity.topAnchor.constraint(equalTo: textFieldTravelEndDate.bottomAnchor, constant: 16),
            labelTravelCountryAndCity.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            textFieldCountryAndCity.topAnchor.constraint(equalTo: labelTravelCountryAndCity.bottomAnchor, constant: 8),
            textFieldCountryAndCity.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            textFieldCountryAndCity.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            buttonAdd.topAnchor.constraint(equalTo: textFieldCountryAndCity.bottomAnchor, constant: 32),
            buttonAdd.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            buttonAdd.widthAnchor.constraint(equalToConstant: 200),
            buttonAdd.heightAnchor.constraint(equalToConstant: 44),
            buttonAdd.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
