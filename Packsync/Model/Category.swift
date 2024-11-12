//
//  Category.swift
//  Packsync
//
//  Created by Xu Yang on 11/11/24.
//

import Foundation

struct Category: Codable {
    var name: String
    var budgetAmount: Double
    var spendingItems: [SpendingItem]
    
    init(
        name: String,
        budgetAmount: Double,
        spendingItems: [SpendingItem] = []
    ) {
        self.name = name
        self.budgetAmount = budgetAmount
        self.spendingItems = spendingItems
    }
}
