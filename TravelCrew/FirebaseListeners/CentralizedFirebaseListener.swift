//
//  CentralizedFirebaseListener.swift
//  TravelCrew
//
//  Created by Leo Yang  on 11/22/24.
//

import Foundation
import FirebaseFirestore

class CentralizedFirebaseListener {
    static let shared = CentralizedFirebaseListener() 
    private let db = Firestore.firestore()
    
    private var travelPlanListener: ListenerRegistration?
    private var categoryListeners: [ListenerRegistration] = []
    private var spendingItemListeners: [ListenerRegistration] = []
    private var balanceListeners: [ListenerRegistration] = []
    private var billboardListeners: [ListenerRegistration] = []
    private var participantListeners: [ListenerRegistration] = []
    
    private init() {} // Private initializer for singleton
    
    // MARK: - Individual Listeners
    
    func listenToTravelPlan(for travelId: String, onUpdate: @escaping (Travel?) -> Void) -> ListenerRegistration? {
        let travelPlanRef = db.collection("travelPlans").document(travelId)
        return travelPlanRef.addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error listening to travel plan: \(error.localizedDescription)")
                onUpdate(nil)
                return
            }
            guard let document = snapshot, document.exists else {
                print("Travel plan document does not exist.")
                onUpdate(nil)
                return
            }
            do {
                let travel = try document.data(as: Travel.self)
                onUpdate(travel)
            } catch {
                print("Error decoding travel document: \(error.localizedDescription)")
                onUpdate(nil)
            }
        }
    }
    
    func listenToCategories(for travelId: String, onUpdate: @escaping ([Category]) -> Void) -> ListenerRegistration {
        let categoriesRef = db.collection("categories").whereField("travelId", isEqualTo: travelId)
        return categoriesRef.addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error listening to categories: \(error.localizedDescription)")
                onUpdate([])
                return
            }
            let categories = snapshot?.documents.compactMap { try? $0.data(as: Category.self) } ?? []
            onUpdate(categories)
        }
    }
    
    func listenToSpendingItems(for travelId: String, onUpdate: @escaping ([SpendingItem]) -> Void) -> ListenerRegistration {
        let spendingItemsRef = db.collection("spendingItems").whereField("travelId", isEqualTo: travelId)
        return spendingItemsRef.addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error listening to spending items: \(error.localizedDescription)")
                onUpdate([])
                return
            }
            let spendingItems = snapshot?.documents.compactMap { try? $0.data(as: SpendingItem.self) } ?? []
            onUpdate(spendingItems)
        }
    }
    
    func listenToBalances(for travelId: String, onUpdate: @escaping ([Balance]) -> Void) -> ListenerRegistration {
        let balancesRef = db.collection("balances").whereField("travelId", isEqualTo: travelId)
        return balancesRef.addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error listening to balances: \(error.localizedDescription)")
                onUpdate([])
                return
            }
            let balances = snapshot?.documents.compactMap { try? $0.data(as: Balance.self) } ?? []
            onUpdate(balances)
        }
    }
    
    func listenToBillboards(for travelId: String, onUpdate: @escaping ([Billboard]) -> Void) -> ListenerRegistration {
        let billboardsRef = db.collection("billboards").whereField("travelId", isEqualTo: travelId)
        return billboardsRef.addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error listening to billboards: \(error.localizedDescription)")
                onUpdate([])
                return
            }
            let billboards = snapshot?.documents.compactMap { try? $0.data(as: Billboard.self) } ?? []
            onUpdate(billboards)
        }
    }
    
    func listenToParticipants(for participantIds: [String], onUpdate: @escaping ([User]) -> Void) -> [ListenerRegistration] {
        guard !participantIds.isEmpty else {
            onUpdate([])
            return []
        }
        var listeners: [ListenerRegistration] = []
        let userCollection = db.collection("users")
        for participantId in participantIds {
            let listener = userCollection.document(participantId).addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error listening to participant with ID \(participantId): \(error.localizedDescription)")
                    return
                }
                guard let document = snapshot, let user = try? document.data(as: User.self) else {
                    print("Participant with ID \(participantId) does not exist or failed to decode.")
                    return
                }
                onUpdate([user])
            }
            listeners.append(listener)
        }
        return listeners
    }
    
    // MARK: - Start Listening to Specific Types
    
    func startListeningToTravelPlan(for travelId: String, onUpdate: @escaping (Travel?) -> Void) {
        stopListeningToTravelPlan()
        travelPlanListener = listenToTravelPlan(for: travelId, onUpdate: onUpdate)
    }
    
    func startListeningToCategories(for travelId: String, onUpdate: @escaping ([Category]) -> Void) {
        stopListeningToCategories()
        categoryListeners.append(listenToCategories(for: travelId, onUpdate: onUpdate))
    }
    
    func startListeningToSpendingItems(for travelId: String, onUpdate: @escaping ([SpendingItem]) -> Void) {
        stopListeningToSpendingItems()
        spendingItemListeners.append(listenToSpendingItems(for: travelId, onUpdate: onUpdate))
    }
    
    func startListeningToBalances(for travelId: String, onUpdate: @escaping ([Balance]) -> Void) {
        stopListeningToBalances()
        balanceListeners.append(listenToBalances(for: travelId, onUpdate: onUpdate))
    }
    
    func startListeningToBillboards(for travelId: String, onUpdate: @escaping ([Billboard]) -> Void) {
        stopListeningToBillboards()
        billboardListeners.append(listenToBillboards(for: travelId, onUpdate: onUpdate))
    }
    
    func startListeningToParticipants(for participantIds: [String], onUpdate: @escaping ([User]) -> Void) {
        stopListeningToParticipants()
        participantListeners = listenToParticipants(for: participantIds, onUpdate: onUpdate)
    }
    
    // MARK: - Stop Listening to Specific Types
    
    func stopListeningToTravelPlan() {
        travelPlanListener?.remove()
        travelPlanListener = nil
    }
    
    func stopListeningToCategories() {
        categoryListeners.forEach { $0.remove() }
        categoryListeners.removeAll()
    }
    
    func stopListeningToSpendingItems() {
        spendingItemListeners.forEach { $0.remove() }
        spendingItemListeners.removeAll()
    }
    
    func stopListeningToBalances() {
        balanceListeners.forEach { $0.remove() }
        balanceListeners.removeAll()
    }
    
    func stopListeningToBillboards() {
        billboardListeners.forEach { $0.remove() }
        billboardListeners.removeAll()
    }
    
    func stopListeningToParticipants() {
        participantListeners.forEach { $0.remove() }
        participantListeners.removeAll()
    }
    
    // MARK: - Start Listening to All
    
    func startListeningToAll(for travelId: String,
                             participantIds: [String],
                             travelUpdate: @escaping (Travel?) -> Void,
                             categoryUpdate: @escaping ([Category]) -> Void,
                             spendingItemsUpdate: @escaping ([SpendingItem]) -> Void,
                             balancesUpdate: @escaping ([Balance]) -> Void,
                             participantsUpdate: @escaping ([User]) -> Void) {
        print("[CentralizedFirebaseListener] Initializing all listeners for travelId: \(travelId).")
        
        stopAllListeners() // Clear any previous listeners

        travelPlanListener = listenToTravelPlan(for: travelId, onUpdate: travelUpdate)
        print("[CentralizedFirebaseListener] Travel plan listener set.")

        categoryListeners.append(listenToCategories(for: travelId, onUpdate: categoryUpdate))
        print("[CentralizedFirebaseListener] Category listeners set.")

        spendingItemListeners.append(listenToSpendingItems(for: travelId, onUpdate: spendingItemsUpdate))
        print("[CentralizedFirebaseListener] Spending items listeners set.")

        balanceListeners.append(listenToBalances(for: travelId, onUpdate: balancesUpdate))
        print("[CentralizedFirebaseListener] Balance listeners set.")
        
        participantListeners = listenToParticipants(for: participantIds, onUpdate: participantsUpdate)
        print("[CentralizedFirebaseListener] Participant listeners set.")
    }
    
    
    // MARK: - Stop All Listeners
    
    func stopAllListeners() {
        travelPlanListener?.remove()
        travelPlanListener = nil
        
        categoryListeners.forEach { $0.remove() }
        categoryListeners.removeAll()
        
        spendingItemListeners.forEach { $0.remove() }
        spendingItemListeners.removeAll()
        
        balanceListeners.forEach { $0.remove() }
        balanceListeners.removeAll()
        
        billboardListeners.forEach { $0.remove() }
        billboardListeners.removeAll()
        
        participantListeners.forEach { $0.remove() }
        participantListeners.removeAll()
    }
    
}
