//
//  SpendingItem.swift
//  Packsync
//
//  Created by Xu Yang on 11/11/24.
//

import Foundation

struct SpendingItem: Codable {
    var amount: Double
    var description: String
    var payerEmail: String
    var date: String
    var receiptURL: String? // Optional: URL to receipt image if uploaded
    
    init(
        amount: Double,
        description: String,
        payerEmail: String,
        date: String,
        receiptURL: String? = nil
    ) {
        self.amount = amount
        self.description = description
        self.payerEmail = payerEmail
        self.date = date
        self.receiptURL = receiptURL
    }
}
