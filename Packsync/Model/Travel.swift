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
    var categoryIds: [String] // Array of IDs for budget categories associated with the travel
    var expenseIds: [String] // Array of IDs for group expenses associated with the travel
    var participantIds: [String] // List of user IDs for participants in the travel plan

    init(
        id: String = UUID().uuidString, // Generate a unique ID if not provided
        creatorId: String,
        travelTitle: String,
        travelStartDate: String,
        travelEndDate: String,
        countryAndCity: String,
        categoryIds: [String] = [],
        expenseIds: [String] = [],
        participantIds: [String] = []
    ) {
        self.id = id
        self.creatorId = creatorId
        self.travelTitle = travelTitle
        self.travelStartDate = travelStartDate
        self.travelEndDate = travelEndDate
        self.countryAndCity = countryAndCity
        self.categoryIds = categoryIds
        self.expenseIds = expenseIds
        self.participantIds = participantIds
    }
}
