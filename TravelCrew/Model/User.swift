//
//  User.swift
//  Packsync
//
//  Created by Xi Jia on 11/8/24.
//

import Foundation

struct User: Codable {
    let id: String // Unique identifier for the user
    let email: String
    let password: String
    var displayName: String?
    var travelIds: [String] = [] // List of travel IDs associated with the user
    // var pendingInvites: [String] = [] // List of pending invite IDs
    var profilePicURL: String? // URL to profile picture

    init(
        id: String = UUID().uuidString, // Generate a unique ID if not provided
        email: String,
        password: String,
        displayName: String? = nil,
        travelIds: [String] = [],
        // pendingInvites: [String] = [],
        profilePicURL: String? = nil
    ) {
        self.id = id
        self.email = email
        self.password = password
        self.displayName = displayName
        self.travelIds = travelIds
        //self.pendingInvites = pendingInvites
        self.profilePicURL = profilePicURL
    }
}
