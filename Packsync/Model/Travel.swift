//
//  Travel.swift
//  Packsync
//
//  Created by Xi Jia on 11/8/24.
//

import Foundation

struct Travel: Codable {
    var creatorEmail: String
    var travelTitle: String
    var travelStartDate: String
    var travelEndDate: String
    var countryAndCity: String
    var budgetCategories: [Category]
    var groupExpenses: [GroupExpense]
    // users:[User]
    
    init(
        creatorEmail: String,
        travelTitle: String,
        travelStartDate: String,
        travelEndDate: String,
        countryAndCity: String,
        budgetCategories: [Category] = [],
        groupExpenses: [GroupExpense] = []
    ) {
        self.creatorEmail = creatorEmail
        self.travelTitle = travelTitle
        self.travelStartDate = travelStartDate
        self.travelEndDate = travelEndDate
        self.countryAndCity = countryAndCity
        self.budgetCategories = budgetCategories
        self.groupExpenses = groupExpenses
    }
}
