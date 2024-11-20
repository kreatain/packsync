//
//  SpendingItem.swift
//  Packsync
//
//  Created by Xu Yang on 11/11/24.
//

import Foundation

struct SpendingItem: Codable {
    var id: String // Unique identifier for the spending item
    var amount: Double
    var description: String
    var date: String
    var receiptURL: String? // Optional: URL to receipt image if uploaded
    var addedByUserId: String // User ID of the person who added the spending item
    var spentByUserId: String // User ID of the person who actually spent the money
    var categoryId: String // ID of the associated category
    var participants: [String] // List of user IDs involved in the split

    init(
        id: String = UUID().uuidString, // Generate a unique ID if not provided
        amount: Double,
        description: String,
        date: String,
        addedByUserId: String,
        spentByUserId: String? = nil, // Defaults to addedByUserId if not provided
        categoryId: String, // Associate a category ID
        receiptURL: String? = nil,
        participants: [String]
    ) {
        self.id = id
        self.amount = amount
        self.description = description
        self.date = date
        self.addedByUserId = addedByUserId
        self.spentByUserId = spentByUserId ?? addedByUserId // Set spentByUserId to addedByUserId if nil
        self.categoryId = categoryId
        self.receiptURL = receiptURL
        self.participants = participants
    }
}
