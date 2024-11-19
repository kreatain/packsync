//
//  Notifications.swift
//  Packsync
//
//  Created by Leo Yang  on 11/15/24.
//

import Foundation

extension Notification.Name {
    /// Notification when travel data changes (e.g., categories, spending items, participants, etc.)
    static let travelDataChanged = Notification.Name("travelDataChanged")
    
    /// Notification when a specific category's data changes (e.g., spending items updated)
    static let categoryDataChanged = Notification.Name("categoryDataChanged")
}
