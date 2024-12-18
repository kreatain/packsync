//
//  Travel.swift
//  Packsync
//
//  Created by Xi Jia on 11/8/24.
//


import Foundation

struct Travel: Codable {
    var id: String // Unique identifier for the travel plan
    var creatorName: String
    var creatorId: String // ID of the user who created the travel plan
    var travelTitle: String
    var travelStartDate: String
    var travelEndDate: String
    var countryAndCity: String
    var currency: String // ISO 4217 currency code (e.g., USD, EUR, JPY)
    var categoryIds: [String] // Array of IDs for budget categories associated with the travel
    var expenseIds: [String] // Array of IDs for spending items associated with the travel [Not In Use]
    var participantIds: [String] // List of user IDs for participants in the travel plan
    var participantNames: [String]
    var balanceIds: [String] // Array of balance IDs for tracking splits
    var billboardIds: [String]

    init(
        id: String = UUID().uuidString, // Generate a unique ID if not provided
        creatorName: String,
        creatorId: String,
        travelTitle: String,
        travelStartDate: String,
        travelEndDate: String,
        countryAndCity: String,
        currency: String = "USD", // Default to USD
        categoryIds: [String] = [],
        expenseIds: [String] = [],
        participantIds: [String] = [],
        participantNames: [String] = [],
        balanceIds: [String] = [],
        billboardIds: [String] = []
    ) {
        self.id = id
        self.creatorName = creatorName
        self.creatorId = creatorId
        self.travelTitle = travelTitle
        self.travelStartDate = travelStartDate
        self.travelEndDate = travelEndDate
        self.countryAndCity = countryAndCity
        self.currency = currency
        self.categoryIds = categoryIds
        self.expenseIds = expenseIds
        self.participantIds = participantIds
        self.participantNames = participantNames
        self.balanceIds = balanceIds
        self.billboardIds = billboardIds
    }
}
