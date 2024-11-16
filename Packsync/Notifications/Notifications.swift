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
    
    /// Add more notifications as needed
    // static let someOtherNotification = Notification.Name("someOtherNotification")
}
