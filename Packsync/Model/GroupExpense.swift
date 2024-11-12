//
//  GroupExpense.swift
//  Packsync
//
//  Created by Xu Yang on 11/8/24.
//

import Foundation

struct GroupExpense: Codable {
    var memberEmail: String
    var amountOwed: Double
    var amountPaid: Double
    
    init(
        memberEmail: String,
        amountOwed: Double = 0.0,
        amountPaid: Double = 0.0
    ) {
        self.memberEmail = memberEmail
        self.amountOwed = amountOwed
        self.amountPaid = amountPaid
    }
}
