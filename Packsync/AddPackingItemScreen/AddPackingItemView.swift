//
//  AddPackingItemView.swift
//  Packsync
//
//  Created by Xi Jia on 11/13/24.
//

import UIKit

class AddPackingItemView: UIView {
    
    var labelTitle: UILabel!
    var textFieldItemName: UITextField!
    var textFieldItemCount: UITextField!
    var buttonAdd: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        setupTextFieldItemName()
        setupTextFieldItemCount()
        setupButtonAdd()
        
        initConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLabelTitle() {
        labelTitle = UILabel()
        labelTitle.text = "Add Packing Item"
        labelTitle.font = UIFont.boldSystemFont(ofSize: 20)
        labelTitle.textAlignment = .center
        labelTitle.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(labelTitle)
    }
    
    func setupTextFieldItemName() {
        textFieldItemName = UITextField()
        textFieldItemName.placeholder = "Enter item name"
        textFieldItemName.borderStyle = .roundedRect
        textFieldItemName.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(textFieldItemName)
    }
    
    func setupTextFieldItemCount() {
        textFieldItemCount = UITextField()
        textFieldItemCount.placeholder = "Enter item count"
        textFieldItemCount.borderStyle = .roundedRect
        textFieldItemCount.keyboardType = .numberPad
        textFieldItemCount.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(textFieldItemCount)
    }
    
    func setupButtonAdd() {
        buttonAdd = UIButton(type: .system)
        buttonAdd.setTitle("Add Item", for: .normal)
        buttonAdd.backgroundColor = .systemBlue
        buttonAdd.setTitleColor(.white, for: .normal)
        buttonAdd.layer.cornerRadius = 8
        buttonAdd.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(buttonAdd)
    }
    
    func initConstraints() {
        NSLayoutConstraint.activate([

            textFieldItemName.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20),
            textFieldItemName.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            textFieldItemName.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            textFieldItemName.heightAnchor.constraint(equalToConstant: 44),
            
            textFieldItemCount.topAnchor.constraint(equalTo: textFieldItemName.bottomAnchor, constant: 20),
            textFieldItemCount.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            textFieldItemCount.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            textFieldItemCount.heightAnchor.constraint(equalToConstant: 44),
            
            buttonAdd.topAnchor.constraint(equalTo: textFieldItemCount.bottomAnchor, constant: 20),
            buttonAdd.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            buttonAdd.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5),
            buttonAdd.heightAnchor.constraint(equalToConstant: 44)
            
            
        ])
    }
}
