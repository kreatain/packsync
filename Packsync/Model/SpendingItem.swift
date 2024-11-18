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
    
    init(
        id: String = UUID().uuidString, // Generate a unique ID if not provided
        amount: Double,
        description: String,
        date: String,
        addedByUserId: String,
        spentByUserId: String? = nil, // Defaults to addedByUserId if not provided
        receiptURL: String? = nil
    ) {
        self.id = id
        self.amount = amount
        self.description = description
        self.date = date
        self.addedByUserId = addedByUserId
        self.spentByUserId = spentByUserId ?? addedByUserId // Set spentByUserId to addedByUserId if nil
        self.receiptURL = receiptURL
    }
}
