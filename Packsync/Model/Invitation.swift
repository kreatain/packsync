//
//  Invitation.swift
//  Packsync
//
//  Created by Xu Yang on 11/11/24.
//

import Foundation

struct Invitation: Codable {
    var id: String // Unique identifier for the invitation
    var senderId: String // ID of the user who sent the invitation
    var receiverId: String // ID of the user who received the invitation
    var travelId: String // ID of the travel plan the invitation is associated with
    var isAccepted: Bool // Indicates whether the invitation has been accepted
    
    init(
        id: String = UUID().uuidString, // Generate a unique ID if not provided
        senderId: String,
        receiverId: String,
        travelId: String,
        isAccepted: Bool = false // Default to false when invitation is created
    ) {
        self.id = id
        self.senderId = senderId
        self.receiverId = receiverId
        self.travelId = travelId
        self.isAccepted = isAccepted
    }
}
