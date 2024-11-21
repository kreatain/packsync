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
    var spendingItemIds: [String] // IDs of spending items contributing to this balance
    var balances: [String: Double] // Key: User ID, Value: Amount owed (+ve) or credited (-ve)
    var isSet: Bool // Indicates whether the balance has been settled
    var createdAt: String // Timestamp for when this balance was created

    init(
        id: String = UUID().uuidString,
        travelId: String,
        spendingItemIds: [String] = [],
        balances: [String: Double] = [:],
        isSet: Bool = false,
        createdAt: String = ISO8601DateFormatter().string(from: Date())
    ) {
        self.id = id
        self.travelId = travelId
        self.spendingItemIds = spendingItemIds
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

extension Balance {
    /// Calculates the minimal transactions needed to settle balances.
    /// Returns an array of tuples representing transactions in the form: (debtorId, creditorId, amount)
    var transactions: [(debtorId: String, creditorId: String, amount: Double)] {
        var debtors = participantBalances.filter { $0.balance < 0 }
        var creditors = participantBalances.filter { $0.balance > 0 }
        
        var result: [(String, String, Double)] = []
        
        while !debtors.isEmpty && !creditors.isEmpty {
            guard let debtor = debtors.popLast(), let creditor = creditors.popLast() else { break }
            
            let amountToSettle = min(abs(debtor.balance), creditor.balance)
            
            result.append((debtor.userId, creditor.userId, amountToSettle))
            
            let debtorRemaining = debtor.balance + amountToSettle
            let creditorRemaining = creditor.balance - amountToSettle
            
            if debtorRemaining < 0 {
                debtors.append((debtor.userId, debtorRemaining))
            }
            if creditorRemaining > 0 {
                creditors.append((creditor.userId, creditorRemaining))
            }
        }
        
        return result
    }
}
