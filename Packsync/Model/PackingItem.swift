//
//  PackingItem.swift
//  Packsync
//
//  Created by 许多 on 10/24/24.
//  Defines individual packing items, including the item name and quantity.

import Foundation

struct PackingItem: Codable {
    var id: String
    var travelId: String
    var name: String
    var isPacked: Bool
    
    init(id: String = UUID().uuidString, travelId: String, name: String, isPacked: Bool = false) {
        self.id = id
        self.travelId = travelId
        self.name = name
        self.isPacked = isPacked
    }
}
