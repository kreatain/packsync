//
//  Invitation.swift
//  Packsync
//
//  Created by Xu Yang/Jessica Li on 11/11/24.
//

import Foundation

struct Invitation: Codable {
    var id: String // Unique identifier for the invitation
    var inviterId: String // ID of the user who sent the invitation
    var receiverId: String // ID of the user who received the invitation
    var travelId: String // ID of the travel plan the invitation is associated with
    var travelTitle: String
    var isAccepted: Int // 0: pending, 1: accept, 2: reject
    var timestamp: Date?
    
    var inviterName: String? // for the sake of querying

    init(
        id: String = UUID().uuidString,
        inviterId: String,
        receiverId: String,
        travelId: String, // No default value, must be provided
        travelTitle: String,
        isAccepted: Int = 0,
        timestamp: Date? = Date(),
        inviterName: String?
    ) {
        self.id = id
        self.inviterId = inviterId
        self.receiverId = receiverId
        self.travelId = travelId
        self.travelTitle = travelTitle
        self.isAccepted = isAccepted
        self.timestamp = timestamp
        self.inviterName = inviterName
    }
}
