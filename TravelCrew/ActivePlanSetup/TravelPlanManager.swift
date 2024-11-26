//
//  TravelPlanManager.swift
//  Packsync
//
//  Created by Xu Yang on 11/11/24.
//

import Foundation
class TravelPlanManager {
    static let shared = TravelPlanManager() // Singleton instance
    
    private(set) var activeTravelPlan: Travel? // The currently active travel plan
    
    private init() {} // Private initializer for singleton
    
    // MARK: - Set Active Travel Plan
    /// Sets the active travel plan to the specified travel.
    func setActiveTravelPlan(_ travelPlan: Travel) {
        activeTravelPlan = travelPlan
        NotificationCenter.default.post(name: .activeTravelPlanChanged, object: nil)
    }
    
    // MARK: - Clear Active Travel Plan
    /// Clears the active travel plan, typically used when logging out or resetting.
    func clearActiveTravelPlan() {
        activeTravelPlan = nil
        UserDefaults.standard.removeObject(forKey: "activePlanData")
        NotificationCenter.default.post(name: .activeTravelPlanChanged, object: nil)
    }
}
