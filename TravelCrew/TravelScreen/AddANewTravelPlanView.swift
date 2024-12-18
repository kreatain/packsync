//
//  AddANewTravelPlanView.swift
//  Packsync
//
//  Created by Xi Jia on 11/7/24.
//

import UIKit

class AddANewTravelPlanView: UIView {
    var scrollView: UIScrollView!
    var contentView: UIView!
    var labelTravelTitle: UILabel!
    var labelTravelStartDate: UILabel!
    var labelTravelEndDate: UILabel!
    var labelTravelCountryAndCity: UILabel!
    var labelCurrency: UILabel!
    var textFieldTravelTitle: UITextField!
    var textFieldTravelStartDate: UITextField!
    var textFieldTravelEndDate: UITextField!
    var textFieldCountryAndCity: UITextField!
    var currencyPicker: UIPickerView!
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
        setupLabelCurrency()
        setupCurrencyPicker()
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

    func setupLabelCurrency() {
        labelCurrency = UILabel()
        labelCurrency.text = "Currency"
        labelCurrency.font = .systemFont(ofSize: 16, weight: .medium)
        labelCurrency.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(labelCurrency)
    }

    func setupCurrencyPicker() {
        currencyPicker = UIPickerView()
        currencyPicker.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(currencyPicker)
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
        labelTravelCountryAndCity.text = "City, Country"
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
        textFieldTravelStartDate.borderStyle = .roundedRect
        textFieldTravelStartDate.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textFieldTravelStartDate)

        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        textFieldTravelStartDate.inputView = datePicker

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.setItems([UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), doneButton], animated: false)
        textFieldTravelStartDate.inputAccessoryView = toolbar
    }

    func setuptextFieldTravelEndDate() {
        textFieldTravelEndDate = UITextField()
        textFieldTravelEndDate.placeholder = "Travel end date"
        textFieldTravelEndDate.borderStyle = .roundedRect
        textFieldTravelEndDate.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textFieldTravelEndDate)

        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.addTarget(self, action: #selector(endDateChanged), for: .valueChanged)
        textFieldTravelEndDate.inputView = datePicker

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(endDateDoneButtonTapped))
        toolbar.setItems([UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), doneButton], animated: false)
        textFieldTravelEndDate.inputAccessoryView = toolbar
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
            scrollView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

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

            labelCurrency.topAnchor.constraint(equalTo: textFieldCountryAndCity.bottomAnchor, constant: 16),
            labelCurrency.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            currencyPicker.topAnchor.constraint(equalTo: labelCurrency.bottomAnchor, constant: 8),
            currencyPicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            currencyPicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            currencyPicker.heightAnchor.constraint(equalToConstant: 150),

            buttonAdd.topAnchor.constraint(equalTo: currencyPicker.bottomAnchor, constant: 32),
            buttonAdd.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            buttonAdd.widthAnchor.constraint(equalToConstant: 200),
            buttonAdd.heightAnchor.constraint(equalToConstant: 44),
            buttonAdd.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    @objc func dateChanged(datePicker: UIDatePicker) {
        textFieldTravelStartDate.text = formatDate(datePicker.date)
    }

    @objc func doneButtonTapped() {
        textFieldTravelStartDate.resignFirstResponder()
    }

    @objc func endDateChanged(datePicker: UIDatePicker) {
        textFieldTravelEndDate.text = formatDate(datePicker.date)
    }

    @objc func endDateDoneButtonTapped() {
        textFieldTravelEndDate.resignFirstResponder()
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
