//
//  Balance.swift
//  Packsync
//
//  Created by Leo Yang  on 11/19/24.
//


import Foundation

struct Balance: Codable {
    var id: String // Unique identifier for the balance instance
    var travelId: String // ID of the travel plan associated with this balance
    var balances: [String: Double] // Key: User ID, Value: Amount owed (+ve) or credited (-ve)
    var isSet: Bool // Indicates whether the balance has been settled
    var createdAt: String // Timestamp for when this balance was created

    init(
        id: String = UUID().uuidString,
        travelId: String,
        balances: [String: Double] = [:],
        isSet: Bool = false,
        createdAt: String = ISO8601DateFormatter().string(from: Date())
    ) {
        self.id = id
        self.travelId = travelId
        self.balances = balances
        self.isSet = isSet
        self.createdAt = createdAt
    }
}

extension Balance {
    var participantBalances: [(userId: String, balance: Double)] {
        return balances.map { ($0.key, $0.value) }.sorted { $0.balance > $1.balance }
    }
}
