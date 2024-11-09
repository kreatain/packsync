//
//  PackingItem.swift
//  Packsync
//
//  Created by Xi Jia on 11/8/24.

import Foundation

struct PackingItem: Codable {
    var id: String
    var creatorEmail: String
    var travelTitle: String
    var name: String
    var isPacked: Bool
    var itemNumber: String?
    
    init(id: String = UUID().uuidString, creatorEmail: String, travelTitle: String, name: String, isPacked: Bool = false, itemNumber: String) {
        self.id = id
        self.creatorEmail = creatorEmail
        self.travelTitle = travelTitle
        self.name = name
        self.isPacked = isPacked
        self.itemNumber = itemNumber
    }
}
