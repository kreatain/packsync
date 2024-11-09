//
//  EditTravelDetailView.swift
//  Packsync
//
//  Created by Xi Jia on 11/8/24.
//

import UIKit

class EditTravelDetailView: UIView {
    
    var labelTravelTitle: UILabel!
    var textFieldTravelTitle: UITextField!
    
    var startDatePicker: UIDatePicker!
    var endDatePicker: UIDatePicker!
    var labelTravelStartDate: UILabel!
    var textFieldTravelStartDate: UITextField!
    var labelTravelEndDate: UILabel!
    var textFieldTravelEndDate: UITextField!
    
    var labelCountryAndCity: UILabel!
    var textFieldCountryAndCity: UITextField!
    
    var buttonSave: UIButton!
    var buttonDelete: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        setupLabelTravelTitle()
        setupTextFieldTravelTitle()
        setupLabelTravelStartDate()
        setupTextFieldTravelStartDate()
        setupLabelTravelEndDate()
        setupTextFieldTravelEndDate()
        setupLabelCountryAndCity()
        setupTextFieldCountryAndCity()
        setupButtonSave()
        setupButtonDelete()
        setupDoneButtons()
        
        initConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLabelTravelTitle() {
        labelTravelTitle = UILabel()
        labelTravelTitle.text = "Travel Title"
        labelTravelTitle.font = UIFont.boldSystemFont(ofSize: 16)
        labelTravelTitle.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(labelTravelTitle)
    }
    
    func setupTextFieldTravelTitle() {
        textFieldTravelTitle = UITextField()
        textFieldTravelTitle.placeholder = "Enter travel title"
        textFieldTravelTitle.borderStyle = .roundedRect
        textFieldTravelTitle.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(textFieldTravelTitle)
    }
    
    func setupLabelTravelStartDate() {
        labelTravelStartDate = UILabel()
        labelTravelStartDate.text = "Start Date"
        labelTravelStartDate.font = UIFont.boldSystemFont(ofSize: 16)
        labelTravelStartDate.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(labelTravelStartDate)
    }
    
    func setupTextFieldTravelStartDate() {
        textFieldTravelStartDate = UITextField()
        textFieldTravelStartDate.placeholder = "Select start date and time"
        textFieldTravelStartDate.borderStyle = .roundedRect
        textFieldTravelStartDate.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(textFieldTravelStartDate)
        setupStartDatePicker()
    }
    
    func setupLabelTravelEndDate() {
        labelTravelEndDate = UILabel()
        labelTravelEndDate.text = "End Date"
        labelTravelEndDate.font = UIFont.boldSystemFont(ofSize: 16)
        labelTravelEndDate.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(labelTravelEndDate)
    }
    
    func setupTextFieldTravelEndDate() {
        textFieldTravelEndDate = UITextField()
        textFieldTravelEndDate.placeholder = "Select end date and time"
        textFieldTravelEndDate.borderStyle = .roundedRect
        textFieldTravelEndDate.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(textFieldTravelEndDate)
        setupEndDatePicker()
    }
    
    func setupLabelCountryAndCity() {
        labelCountryAndCity = UILabel()
        labelCountryAndCity.text = "Country and City"
        labelCountryAndCity.font = UIFont.boldSystemFont(ofSize: 16)
        labelCountryAndCity.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(labelCountryAndCity)
    }
    
    func setupTextFieldCountryAndCity() {
        textFieldCountryAndCity = UITextField()
        textFieldCountryAndCity.placeholder = "Enter country and city"
        textFieldCountryAndCity.borderStyle = .roundedRect
        textFieldCountryAndCity.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(textFieldCountryAndCity)
    }
    
    func setupButtonSave() {
        buttonSave = UIButton(type: .system)
        buttonSave.setTitle("Save Changes", for: .normal)
        buttonSave.backgroundColor = .systemBlue
        buttonSave.setTitleColor(.white, for: .normal)
        buttonSave.layer.cornerRadius = 8
        buttonSave.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(buttonSave)
    }

    func setupButtonDelete() {
        buttonDelete = UIButton(type: .system)
        buttonDelete.setTitle("Delete Travel Plan", for: .normal)
        buttonDelete.setTitleColor(.white, for: .normal)
        buttonDelete.backgroundColor = .systemRed
        buttonDelete.layer.cornerRadius = 8
        buttonDelete.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(buttonDelete)
    }
    
    func setupStartDatePicker() {
        startDatePicker = UIDatePicker()
        startDatePicker.datePickerMode = .dateAndTime
        startDatePicker.preferredDatePickerStyle = .wheels
        startDatePicker.addTarget(self, action: #selector(startDateChanged), for: .valueChanged)
        textFieldTravelStartDate.inputView = startDatePicker
    }

    func setupEndDatePicker() {
        endDatePicker = UIDatePicker()
        endDatePicker.datePickerMode = .dateAndTime
        endDatePicker.preferredDatePickerStyle = .wheels
        endDatePicker.addTarget(self, action: #selector(endDateChanged), for: .valueChanged)
        textFieldTravelEndDate.inputView = endDatePicker
    }
    
    @objc func startDateChanged() {
        textFieldTravelStartDate.text = formatDate(startDatePicker.date)
    }

    @objc func endDateChanged() {
        textFieldTravelEndDate.text = formatDate(endDatePicker.date)
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy HH:mm"
        return formatter.string(from: date)
    }
    
    func initConstraints() {
        NSLayoutConstraint.activate([
            labelTravelTitle.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20),
            labelTravelTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            labelTravelTitle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            textFieldTravelTitle.topAnchor.constraint(equalTo: labelTravelTitle.bottomAnchor, constant: 5),
            textFieldTravelTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            textFieldTravelTitle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            labelTravelStartDate.topAnchor.constraint(equalTo: textFieldTravelTitle.bottomAnchor, constant: 20),
            labelTravelStartDate.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            labelTravelStartDate.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            textFieldTravelStartDate.topAnchor.constraint(equalTo: labelTravelStartDate.bottomAnchor, constant: 5),
            textFieldTravelStartDate.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            textFieldTravelStartDate.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            labelTravelEndDate.topAnchor.constraint(equalTo: textFieldTravelStartDate.bottomAnchor, constant: 20),
            labelTravelEndDate.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            labelTravelEndDate.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            textFieldTravelEndDate.topAnchor.constraint(equalTo: labelTravelEndDate.bottomAnchor, constant: 5),
            textFieldTravelEndDate.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            textFieldTravelEndDate.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            labelCountryAndCity.topAnchor.constraint(equalTo: textFieldTravelEndDate.bottomAnchor, constant: 20),
            labelCountryAndCity.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            labelCountryAndCity.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            textFieldCountryAndCity.topAnchor.constraint(equalTo: labelCountryAndCity.bottomAnchor, constant: 5),
            textFieldCountryAndCity.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            textFieldCountryAndCity.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            buttonSave.topAnchor.constraint(equalTo: textFieldCountryAndCity.bottomAnchor, constant: 20),
            buttonSave.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            buttonSave.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            buttonSave.heightAnchor.constraint(equalToConstant: 44),

            buttonDelete.topAnchor.constraint(equalTo: buttonSave.bottomAnchor, constant: 20),
            buttonDelete.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            buttonDelete.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            buttonDelete.heightAnchor.constraint(equalToConstant: 44),
            buttonDelete.bottomAnchor.constraint(lessThanOrEqualTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    func configure(with travel: Travel) {
        textFieldTravelTitle.text = travel.travelTitle
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm"
        
        if let startDate = dateFormatter.date(from: travel.travelStartDate) {
            startDatePicker.date = startDate
            textFieldTravelStartDate.text = formatDate(startDate)
        }
        
        if let endDate = dateFormatter.date(from: travel.travelEndDate) {
            endDatePicker.date = endDate
            textFieldTravelEndDate.text = formatDate(endDate)
        }
        
        textFieldCountryAndCity.text = travel.countryAndCity
    }
    
    func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "MMM dd, yyyy HH:mm"

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd"

        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }

        return dateString // Return original string if parsing fails
    }
    
    func setupDoneButtons() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissDatePicker))
        toolBar.setItems([doneButton], animated: false)
        textFieldTravelStartDate.inputAccessoryView = toolBar
        textFieldTravelEndDate.inputAccessoryView = toolBar
    }

    @objc func dismissDatePicker() {
        self.endEditing(true)
    }
}
