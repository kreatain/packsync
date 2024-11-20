//
//  SpendingFirebaseManager.swift
//  Packsync
//
//  Created by Xu Yang on 11/11/24.
//

import Foundation
import FirebaseFirestore

import Foundation
import FirebaseFirestore

class SpendingFirebaseManager {
    static let shared = SpendingFirebaseManager() // Singleton instance
    private let db = Firestore.firestore() // Firestore database reference
    
    private init() {} // Private initializer for singleton
    
    // MARK: - Fetch Travel
    func fetchTravel(for travelId: String, completion: @escaping (Travel?) -> Void) {
        guard !travelId.isEmpty else {
            print("Error: travelId is empty.")
            completion(nil)
            return
        }
        
        db.collection("travelPlans").document(travelId).getDocument(source: .server) { snapshot, error in
            guard let document = snapshot, error == nil, document.exists else {
                print("Error fetching travel: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            do {
                let travel = try document.data(as: Travel.self)
                print("Successfully fetched travel with ID: \(travelId)")
                completion(travel)
            } catch {
                print("Error decoding travel document: \(error)")
                completion(nil)
            }
        }
    }
    
    // MARK: - Fetch Categories by IDs
    func fetchCategoriesByIds(categoryIds: [String], completion: @escaping ([Category]) -> Void) {
        print("Starting fetchCategoriesByIds with category IDs: \(categoryIds)")
        let categoriesRef = db.collection("categories")
        let dispatchGroup = DispatchGroup()
        var categories: [Category] = []
        
        for categoryId in categoryIds {
            print("Fetching category with ID: \(categoryId)")
            dispatchGroup.enter()
            categoriesRef.document(categoryId).getDocument { document, error in
                if let error = error {
                    print("Error fetching category \(categoryId): \(error.localizedDescription)")
                    dispatchGroup.leave()
                    return
                }
                if let document = document, let category = try? document.data(as: Category.self) {
                    print("Successfully fetched category with ID: \(categoryId) - Name: \(category.name), Budget: \(category.budgetAmount)")
                    categories.append(category)
                } else {
                    print("Category with ID: \(categoryId) not found or failed to decode.")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("Finished fetching categories. Total fetched: \(categories.count)")
            for category in categories {
                print(" - Category ID: \(category.id), Name: \(category.name), Budget: \(category.budgetAmount)")
            }
            completion(categories)
        }
    }

    // MARK: - Fetch Users by IDs
    func fetchUsersByIds(userIds: [String], completion: @escaping ([User]) -> Void) {
        let userCollection = db.collection("users")
        let dispatchGroup = DispatchGroup()
        var users: [User] = []
        
        for userId in userIds {
            dispatchGroup.enter()
            userCollection.document(userId).getDocument { document, error in
                if let error = error {
                    print("Error fetching user \(userId): \(error.localizedDescription)")
                    dispatchGroup.leave()
                    return
                }
                if let document = document, let user = try? document.data(as: User.self) {
                    users.append(user)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(users)
        }
    }
    
    
    
    // MARK: - Fetch Spending Items by IDs
    func fetchSpendingItemsByIds(spendingItemIds: [String], completion: @escaping ([SpendingItem]) -> Void) {
        print("Starting fetchSpendingItemsByIds with IDs: \(spendingItemIds)")
        let spendingItemsRef = db.collection("spendingItems")
        let dispatchGroup = DispatchGroup()
        var spendingItems: [SpendingItem] = []

        for spendingItemId in spendingItemIds {
            print("Fetching spending item with ID: \(spendingItemId)")
            dispatchGroup.enter()
            spendingItemsRef.document(spendingItemId).getDocument { document, error in
                if let error = error {
                    print("Error fetching spending item \(spendingItemId): \(error.localizedDescription)")
                    dispatchGroup.leave()
                    return
                }
                if let document = document, let spendingItem = try? document.data(as: SpendingItem.self) {
                    print("Successfully fetched spending item: \(spendingItem)")
                    spendingItems.append(spendingItem)
                } else {
                    print("Spending item with ID \(spendingItemId) not found or failed to decode.")
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            print("Finished fetching spending items. Total fetched: \(spendingItems.count)")
            completion(spendingItems)
        }
    }
    
    // MARK: - Fetch Spending Items by Category IDs
    func fetchSpendingItemsByCategoryIds(categoryIds: [String], completion: @escaping ([SpendingItem]) -> Void) {
        print("Starting fetchSpendingItemsByCategoryIds for category IDs: \(categoryIds)")

        // Early exit if categoryIds is empty
        guard !categoryIds.isEmpty else {
            print("fetchSpendingItemsByCategoryIds: No category IDs provided.")
            completion([])
            return
        }

        let spendingItemsRef = db.collection("spendingItems")
        let dispatchGroup = DispatchGroup()
        var spendingItems: [SpendingItem] = []

        for categoryId in categoryIds {
            dispatchGroup.enter()
            spendingItemsRef.whereField("categoryId", isEqualTo: categoryId).getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching spending items for category ID \(categoryId): \(error.localizedDescription)")
                } else if let documents = snapshot?.documents {
                    let items = documents.compactMap { try? $0.data(as: SpendingItem.self) }
                    spendingItems.append(contentsOf: items)
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            print("Finished fetching spending items. Total fetched: \(spendingItems.count)")
            completion(spendingItems)
        }
    }
    

    // MARK: - Add Spending Item
    func addSpendingItem(to categoryId: String, spendingItem: SpendingItem, completion: @escaping (Bool) -> Void) {
        let spendingItemsRef = db.collection("spendingItems")
        let categoryRef = db.collection("categories").document(categoryId)
        
        // Generate a new spending item with a unique ID
        var spendingItemToAdd = spendingItem
        let newSpendingItemRef = spendingItemsRef.document() // Generate a new document ID
        spendingItemToAdd.id = newSpendingItemRef.documentID // Assign the generated ID
        spendingItemToAdd.categoryId = categoryId // Ensure categoryId is assigned

        do {
            // Add the spending item to the spendingItems collection
            try newSpendingItemRef.setData(from: spendingItemToAdd) { error in
                if let error = error {
                    print("Error adding spending item: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                // Update the category to include the new spending item ID
                categoryRef.updateData([
                    "spendingItemIds": FieldValue.arrayUnion([spendingItemToAdd.id]) // Add the ID to the array
                ]) { error in
                    if let error = error {
                        print("Error updating category with new spending item ID: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("Spending item added successfully and linked to category ID: \(categoryId)")
                        completion(true)
                    }
                }
            }
        } catch {
            print("Error serializing spending item for add: \(error.localizedDescription)")
            completion(false)
        }
    }

    // MARK: - Update Spending Item
    func updateSpendingItem(spendingItem: SpendingItem, completion: @escaping (Bool) -> Void) {
        let spendingItemRef = db.collection("spendingItems").document(spendingItem.id)

        do {
            try spendingItemRef.setData(from: spendingItem) { error in
                if let error = error {
                    print("Error updating spending item: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Spending item updated successfully.")
                    completion(true)
                }
            }
        } catch {
            print("Error serializing spending item for update: \(error.localizedDescription)")
            completion(false)
        }
    }

    // MARK: - Delete Spending Item
    func deleteSpendingItem(from categoryId: String, spendingItemId: String, completion: @escaping (Bool) -> Void) {
        let spendingItemRef = db.collection("spendingItems").document(spendingItemId)
        let categoryRef = db.collection("categories").document(categoryId)

        // Delete the spending item
        spendingItemRef.delete { error in
            if let error = error {
                print("Error deleting spending item: \(error.localizedDescription)")
                completion(false)
                return
            }

            // Update the category to remove the spending item ID
            categoryRef.updateData([
                "spendingItemIds": FieldValue.arrayRemove([spendingItemId])
            ]) { error in
                if let error = error {
                    print("Error updating category after spending item deletion: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Spending item deleted successfully and unlinked from category.")
                    completion(true)
                }
            }
        }
    }
    
    func addCategory(to travelId: String, category: Category, completion: @escaping (Bool) -> Void) {
        let categoryRef = db.collection("categories").document() // Generate a new document ID
        var categoryToAdd = category // Create a mutable copy of the category
        categoryToAdd.id = categoryRef.documentID // Set the category's ID to match the Firestore document ID

        let travelPlanRef = db.collection("travelPlans").document(travelId)

        // Create the new category in Firestore
        do {
            try categoryRef.setData(from: categoryToAdd) { error in
                guard error == nil else {
                    print("Error adding category: \(error!)")
                    completion(false)
                    return
                }

                // Update the travelPlan to include the new category ID
                travelPlanRef.updateData([
                    "categoryIds": FieldValue.arrayUnion([categoryRef.documentID])
                ]) { error in
                    if let error = error {
                        print("Error updating travel plan with new category ID: \(error)")
                        completion(false)
                    } else {
                        print("Successfully added category and updated travel plan.")
                        
                        // Post a notification about the change
                        NotificationCenter.default.post(
                            name: .travelDataChanged, // Custom notification name
                            object: nil,
                            userInfo: [
                                "travelId": travelId,
                                "categoryId": categoryRef.documentID,
                                "categoryName": category.name
                            ]
                        )
                        
                        completion(true)
                    }
                }
            }
        } catch {
            print("Error encoding category: \(error)")
            completion(false)
        }
    }
    
    // MARK: - Update Category
    func updateCategory(in travelId: String, category: Category, completion: @escaping (Bool) -> Void) {
        let categoryRef = db.collection("categories").document(category.id)
        do {
            try categoryRef.setData(from: category) { error in
                if let error = error {
                    print("Error updating category: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Category updated successfully.")
                    completion(true)
                }
            }
        } catch {
            print("Error serializing category for update: \(error.localizedDescription)")
            completion(false)
        }
    }

    // MARK: - Delete Category and Spending Items
    func deleteCategory(from travelId: String, categoryId: String, completion: @escaping (Bool) -> Void) {
        let categoryRef = db.collection("categories").document(categoryId)
        let travelRef = db.collection("travelPlans").document(travelId)

        print("Initiating deletion for category ID: \(categoryId) from travel plan ID: \(travelId)")

        // Fetch the category document to get `spendingItemIds`
        categoryRef.getDocument { document, error in
            guard let document = document, document.exists, error == nil else {
                print("Error fetching category document: \(error?.localizedDescription ?? "Unknown error"). Document exists: \(document?.exists ?? false)")
                completion(false)
                return
            }

            guard let data = document.data(),
                  let spendingItemIds = data["spendingItemIds"] as? [String] else {
                print("Category document \(categoryId) is missing spendingItemIds or data is invalid.")
                completion(false)
                return
            }

            print("Fetched category document with ID: \(categoryId). Spending item IDs: \(spendingItemIds)")

            let batch = self.db.batch()

            // Check if there are spending items to delete
            if spendingItemIds.isEmpty {
                print("No spending items to delete for category \(categoryId).")
            } else {
                // Remove spending items from the `spendingItems` table
                let spendingItemsRef = self.db.collection("spendingItems")
                for spendingItemId in spendingItemIds {
                    let spendingItemRef = spendingItemsRef.document(spendingItemId)
                    print("Queuing deletion for spending item ID: \(spendingItemId) from spendingItems table")
                    batch.deleteDocument(spendingItemRef)
                }
            }

            // Delete the category document
            print("Queuing deletion for category document with ID: \(categoryId)")
            batch.deleteDocument(categoryRef)

            // Update the travel plan to remove the category ID
            print("Queuing removal of category ID \(categoryId) from travel plan \(travelId)")
            batch.updateData(["categoryIds": FieldValue.arrayRemove([categoryId])], forDocument: travelRef)

            // Commit the batch
            batch.commit { error in
                if let error = error {
                    print("Error during batch commit: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Successfully deleted category ID \(categoryId) and its associated spending items from travel plan ID \(travelId).")
                    // Post notification for data change
                    NotificationCenter.default.post(
                        name: .travelDataChanged,
                        object: nil,
                        userInfo: [
                            "travelId": travelId,
                            "deletedCategoryId": categoryId
                        ]
                    )
                    completion(true)
                }
            }
        }
    }
    
    // MARK: - Add Balance
        func addBalance(for travelId: String, balance: Balance, completion: @escaping (Bool) -> Void) {
            let balanceRef = db.collection("balances").document(balance.id)
            let travelRef = db.collection("travelPlans").document(travelId)
            
            do {
                try balanceRef.setData(from: balance) { error in
                    if let error = error {
                        print("Error adding balance: \(error.localizedDescription)")
                        completion(false)
                        return
                    }
                    
                    // Update the travel plan to include the new balance ID
                    travelRef.updateData([
                        "balanceIds": FieldValue.arrayUnion([balance.id]) // Add balance ID to the list
                    ]) { error in
                        if let error = error {
                            print("Error updating travel plan with new balance ID: \(error.localizedDescription)")
                            completion(false)
                        } else {
                            print("Balance added and linked to travel plan successfully.")
                            completion(true)
                        }
                    }
                }
            } catch {
                print("Error serializing balance: \(error.localizedDescription)")
                completion(false)
            }
        }
    
    // MARK: - Fetch Single Balance
    func fetchBalance(byId balanceId: String, completion: @escaping (Balance?) -> Void) {
        db.collection("balances").document(balanceId).getDocument { document, error in
            if let error = error {
                print("Error fetching balance: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let document = document, let balance = try? document.data(as: Balance.self) {
                completion(balance)
            } else {
                print("Balance with ID \(balanceId) not found or failed to decode.")
                completion(nil)
            }
        }
    }
    
    // MARK: - Fetch All Balances for a Travel Plan
        func fetchBalances(for travelId: String, completion: @escaping ([Balance]) -> Void) {
            db.collection("balances")
                .whereField("travelId", isEqualTo: travelId)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("Error fetching balances: \(error.localizedDescription)")
                        completion([])
                        return
                    }

                    let balances = snapshot?.documents.compactMap { document in
                        try? document.data(as: Balance.self)
                    } ?? []

                    print("Fetched \(balances.count) balances for travel ID \(travelId).")
                    completion(balances)
                }
        }
    
    // MARK: - Fetch Active Balance
        func fetchActiveBalance(for travelId: String, completion: @escaping (Balance?) -> Void) {
            db.collection("balances")
                .whereField("travelId", isEqualTo: travelId)
                .whereField("isSet", isEqualTo: false)
                .limit(to: 1)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("Error fetching active balance: \(error.localizedDescription)")
                        completion(nil)
                        return
                    }

                    if let document = snapshot?.documents.first {
                        let activeBalance = try? document.data(as: Balance.self)
                        completion(activeBalance)
                    } else {
                        completion(nil)
                    }
                }
        }
    
    // MARK: - Ensure Single Active Balance
        func ensureActiveBalance(for travelId: String, completion: @escaping (Balance?) -> Void) {
            fetchActiveBalance(for: travelId) { activeBalance in
                if let activeBalance = activeBalance {
                    // Return existing active balance
                    print("Active balance already exists for travel ID \(travelId).")
                    completion(activeBalance)
                } else {
                    // Create a new active balance if none exists
                    self.createNewBalance(for: travelId, completion: completion)
                }
            }
        }
    
    // MARK: - Create New Balance
        func createNewBalance(for travelId: String, completion: @escaping (Balance?) -> Void) {
            let newBalance = Balance(travelId: travelId)

            addBalance(for: travelId, balance: newBalance) { success in
                if success {
                    print("New balance created successfully with ID \(newBalance.id).")
                    completion(newBalance)
                } else {
                    print("Failed to create new balance.")
                    completion(nil)
                }
            }
        }
    
    // MARK: - Update Balance
    func updateBalance(balance: Balance, completion: @escaping (Bool) -> Void) {
        let balanceRef = db.collection("balances").document(balance.id)
        
        do {
            try balanceRef.setData(from: balance) { error in
                if let error = error {
                    print("Error updating balance: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Balance updated successfully.")
                    completion(true)
                }
            }
        } catch {
            print("Error serializing balance: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    // MARK: - Delete Balance
        func deleteBalance(for travelId: String, balanceId: String, completion: @escaping (Bool) -> Void) {
            let balanceRef = db.collection("balances").document(balanceId)
            let travelRef = db.collection("travelPlans").document(travelId)

            balanceRef.delete { error in
                if let error = error {
                    print("Error deleting balance: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                // Update the travel plan to remove the balance ID
                travelRef.updateData([
                    "balanceIds": FieldValue.arrayRemove([balanceId]) // Remove balance ID from the list
                ]) { error in
                    if let error = error {
                        print("Error updating travel plan after balance deletion: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("Balance deleted and unlinked from travel plan successfully.")
                        completion(true)
                    }
                }
            }
        }
    
}

extension Locale {
    /// Helper to get the currency symbol from a currency code
    func currencySymbol(for currencyCode: String) -> String? {
        let locale = Locale.availableIdentifiers
            .compactMap { Locale(identifier: $0) }
            .first { $0.currencyCode == currencyCode }
        return locale?.currencySymbol
    }
}
