//
//  GroupExpense.swift
//  Packsync
//
//  Created by Xu Yang on 11/8/24.
//

import Foundation

struct GroupExpense: Codable {
    var id: String // Unique identifier for the group expense
    var travelId: String // ID of the travel plan associated with this expense
    var userId: String // Unique identifier for the user associated with this expense
    var amountOwed: Double
    var amountPaid: Double
    var isSet: Bool // Indicates whether the expense has been settled or finalized
    
    init(
        id: String = UUID().uuidString, // Generate a unique ID if not provided
        travelId: String,
        userId: String,
        amountOwed: Double = 0.0,
        amountPaid: Double = 0.0,
        isSet: Bool = false
    ) {
        self.id = id
        self.travelId = travelId
        self.userId = userId
        self.amountOwed = amountOwed
        self.amountPaid = amountPaid
        self.isSet = isSet
    }
}
