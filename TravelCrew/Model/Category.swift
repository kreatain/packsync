//
//  Category.swift
//  Packsync
//
//  Created by Xu Yang on 11/11/24.
//

import Foundation

struct Category: Codable {
    var id: String // Unique identifier for the category
    var name: String
    var budgetAmount: Double
    var emoji: String // Emoji for category representation
    var spendingItemIds: [String]// Array of IDs for spending items associated with the category
    var travelId: String

    init(
        id: String = UUID().uuidString, // Generate a unique ID if not provided
        name: String,
        budgetAmount: Double,
        emoji: String,
        spendingItemIds: [String] = [],
        travelId: String
    ) {
        self.id = id
        self.name = name
        self.budgetAmount = budgetAmount
        self.emoji = emoji
        self.spendingItemIds = spendingItemIds
        self.travelId = travelId
    }
    
    // This would require a function to calculate total spent by fetching all SpendingItem objects by ID
    func calculateTotalSpent(using spendingItems: [SpendingItem]) -> Double {
        return spendingItems.reduce(0) { $0 + $1.amount }
    }
}
