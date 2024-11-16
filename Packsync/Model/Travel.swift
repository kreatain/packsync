//
//  Travel.swift
//  Packsync
//
//  Created by Xi Jia on 11/8/24.
//


import Foundation

struct Travel: Codable {
    var id: String // Unique identifier for the travel plan
    var creatorId: String // ID of the user who created the travel plan
    var travelTitle: String
    var travelStartDate: String
    var travelEndDate: String
    var countryAndCity: String
    var currency: String // ISO 4217 currency code (e.g., USD, EUR, JPY)
    var categoryIds: [String] // Array of IDs for budget categories associated with the travel
    var expenseIds: [String] // Array of IDs for group expenses associated with the travel
    var participantIds: [String] // List of user IDs for participants in the travel plan
    var billboardIds: [String]

    init(
        id: String = UUID().uuidString, // Generate a unique ID if not provided
        creatorId: String,
        travelTitle: String,
        travelStartDate: String,
        travelEndDate: String,
        countryAndCity: String,
        currency: String = "USD", // Default to USD
        categoryIds: [String] = [],
        expenseIds: [String] = [],
        participantIds: [String] = [],
        billboardIds: [String] = []
    ) {
        self.id = id
        self.creatorId = creatorId
        self.travelTitle = travelTitle
        self.travelStartDate = travelStartDate
        self.travelEndDate = travelEndDate
        self.countryAndCity = countryAndCity
        self.currency = currency
        self.categoryIds = categoryIds
        self.expenseIds = expenseIds
        self.participantIds = participantIds
        self.billboardIds = billboardIds
    }
}
