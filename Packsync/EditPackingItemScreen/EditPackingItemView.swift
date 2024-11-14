//
//  EditPackingItemView.swift
//  Packsync
//
//  Created by Xi Jia on 11/13/24.
//

import UIKit

class EditPackingItemView: UIView {
    
    var labelItemName: UILabel!
    var textFieldItemName: UITextField!
    var labelItemCount: UILabel!
    var textFieldItemCount: UITextField!
    var buttonSave: UIButton!
    var buttonDelete: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        setupLabelItemName()
        setupTextFieldItemName()
        setupLabelItemCount()
        setupTextFieldItemCount()
        setupButtonSave()
        setupButtonDelete()
        
        initConstraints()
    }
    
    func setupLabelItemName() {
        labelItemName = UILabel()
        labelItemName.text = "Item Name:"
        labelItemName.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(labelItemName)
    }
    
    func setupTextFieldItemName() {
        textFieldItemName = UITextField()
        textFieldItemName.borderStyle = .roundedRect
        textFieldItemName.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(textFieldItemName)
    }
    
    func setupLabelItemCount() {
        labelItemCount = UILabel()
        labelItemCount.text = "Item Count:"
        labelItemCount.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(labelItemCount)
    }
    
    func setupTextFieldItemCount() {
        textFieldItemCount = UITextField()
        textFieldItemCount.borderStyle = .roundedRect
        textFieldItemCount.keyboardType = .numberPad
        textFieldItemCount.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(textFieldItemCount)
    }
    
    func setupButtonSave() {
        buttonSave = UIButton(type: .system)
        buttonSave.setTitle("Save Changes", for: .normal)
        buttonSave.setTitleColor(.white, for: .normal)
        buttonSave.backgroundColor = .systemBlue
        buttonSave.layer.cornerRadius = 8
        buttonSave.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(buttonSave)
    }
    
    func setupButtonDelete() {
        buttonDelete = UIButton(type: .system)
        buttonDelete.setTitle("Delete Item", for: .normal)
        buttonDelete.setTitleColor(.white, for: .normal)
        buttonDelete.backgroundColor = .systemRed
        buttonDelete.layer.cornerRadius = 8
        buttonDelete.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(buttonDelete)
    }
    
    func initConstraints() {
        NSLayoutConstraint.activate([
            labelItemName.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20),
            labelItemName.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            
            textFieldItemName.topAnchor.constraint(equalTo: labelItemName.bottomAnchor, constant: 8),
            textFieldItemName.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            textFieldItemName.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            labelItemCount.topAnchor.constraint(equalTo: textFieldItemName.bottomAnchor, constant: 20),
            labelItemCount.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            
            textFieldItemCount.topAnchor.constraint(equalTo: labelItemCount.bottomAnchor, constant: 8),
            textFieldItemCount.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            textFieldItemCount.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            buttonSave.topAnchor.constraint(equalTo: textFieldItemCount.bottomAnchor, constant: 40),
            buttonSave.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            buttonSave.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            buttonSave.heightAnchor.constraint(equalToConstant: 44),
            
            buttonDelete.topAnchor.constraint(equalTo: buttonSave.bottomAnchor, constant: 20),
            buttonDelete.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            buttonDelete.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            buttonDelete.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
