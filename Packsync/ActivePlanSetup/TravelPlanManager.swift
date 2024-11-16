//
//  TravelPlanManager.swift
//  Packsync
//
//  Created by Xu Yang on 11/11/24.
//

import Foundation
import FirebaseFirestore

class TravelPlanManager {
    static let shared = TravelPlanManager()
        
        private(set) var activeTravelPlan: Travel?
        private let db = Firestore.firestore()
        private let defaults = UserDefaults.standard
        
        private init() {
            loadActiveTravelPlan()
        }
        
    private func loadActiveTravelPlan() {
            if let activeTravelPlanId = defaults.string(forKey: "activeTravelPlanId") {
                db.collection("travelPlans").document(activeTravelPlanId).getDocument { [weak self] (document, error) in
                    if let document = document, document.exists, let data = document.data() {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: data)
                            let decoder = JSONDecoder()
                            let travel = try decoder.decode(Travel.self, from: jsonData)
                            self?.activeTravelPlan = travel
                            NotificationCenter.default.post(name: .activeTravelPlanChanged, object: nil)
                        } catch {
                            print("Error decoding Travel: \(error)")
                        }
                    }
                }
            }
        }
        
        func clearActiveTravelPlan() {
            print("Clearing active travel plan")
            if let previousActive = activeTravelPlan {
                updateTravelPlanActiveStatus(previousActive.id, isActive: false)
            }
            activeTravelPlan = nil
            defaults.removeObject(forKey: "activeTravelPlanId")
            NotificationCenter.default.post(name: .activeTravelPlanChanged, object: nil)
        }
        
        func setActiveTravelPlan(_ travelPlan: Travel) {
            print("Setting active travel plan with ID: \(travelPlan.id)")
            if let previousActive = activeTravelPlan {
                updateTravelPlanActiveStatus(previousActive.id, isActive: false)
            }
            
            activeTravelPlan = travelPlan
            updateTravelPlanActiveStatus(travelPlan.id, isActive: true)
            defaults.set(travelPlan.id, forKey: "activeTravelPlanId")
            NotificationCenter.default.post(name: .activeTravelPlanChanged, object: nil)
        }
    
    private func updateTravelPlanActiveStatus(_ travelPlanId: String, isActive: Bool) {
            print("Updating travel plan \(travelPlanId) isActive status to \(isActive)")
            let docRef = db.collection("travelPlans").document(travelPlanId)
            docRef.updateData(["isActive": isActive]) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                } else {
                    print("Document successfully updated")
                    // Verify the update by fetching the document
                    docRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                            print("Document data after update: \(dataDescription)")
                        } else {
                            print("Document does not exist")
                        }
                    }
                }
            }
        }
}
