//
//  PackingItem.swift
//  Packsync
//
//  Created by Xi Jia on 11/8/24.

import Foundation

struct PackingItem: Codable {
    var id: String // Unique identifier for the packing item
    var creatorId: String // ID of the user who created the item
    var travelId: String // ID of the travel plan the item is associated with
    var name: String
    var isPacked: Bool
    var itemNumber: String // Quantity or count of the item
    
    init(
        id: String = UUID().uuidString,
        creatorId: String,
        travelId: String,
        name: String,
        isPacked: Bool = false,
        itemNumber: String
    ) {
        self.id = id
        self.creatorId = creatorId
        self.travelId = travelId
        self.name = name
        self.isPacked = isPacked
        self.itemNumber = itemNumber
    }
}
