//
//  Invitation.swift
//  Packsync
//
//  Created by Xu Yang/Jessica Li on 11/11/24.
//

//
//  Invitation.swift
//  Packsync
//
//  Created by Xu Yang on 11/11/24.
//

import Foundation

struct Invitation: Codable {
    var id: String // Unique identifier for the invitation
    var inviterId: String // ID of the user who sent the invitation
    var inviterName: String // Name of the user who sent the invitation
    var receiverId: String // ID of the user who received the invitation
    var travelId: String // ID of the travel plan the invitation is associated with
    var travelTitle: String // Title of the travel plan (new field)
    var isAccepted: Bool // Indicates whether the invitation has been accepted

    init(
        id: String = UUID().uuidString,
        inviterId: String,
        inviterName: String,
        receiverId: String,
        travelId: String,
        travelTitle: String = "Unknown Trip", // Default value if travel title is unavailable
        isAccepted: Bool = false
    ) {
        self.id = id
        self.inviterId = inviterId
        self.inviterName = inviterName
        self.receiverId = receiverId
        self.travelId = travelId
        self.travelTitle = travelTitle
        self.isAccepted = isAccepted
    }
}
