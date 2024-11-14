//
//  SpendingFirebaseManager.swift
//  Packsync
//
//  Created by Xu Yang on 11/11/24.
//

import Foundation
import FirebaseFirestore

class SpendingFirebaseManager {
    static let shared = SpendingFirebaseManager() // Singleton instance
    private let db = Firestore.firestore() // Firestore database reference
    
    private init() {} // Private initializer for singleton
    
    // MARK: - Fetch Categories with Spending Item IDs for a Specific Trip
    /// Fetches categories and their associated spending item IDs for a specific trip.
    func fetchCategories(for travelId: String, completion: @escaping ([Category]) -> Void) {
        db.collection("trips").document(travelId).collection("budgetCategories")
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching categories: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                let categories = snapshot?.documents.compactMap { document -> Category? in
                    var category = try? document.data(as: Category.self)
                    category?.id = document.documentID // Ensure the category ID is set
                    return category
                } ?? []
                
                completion(categories)
            }
    }
    
    // MARK: - Fetch Spending Items for a Category
    /// Fetches all spending items associated with a specific category in a trip.
    func fetchSpendingItems(for travelId: String, categoryId: String, completion: @escaping ([SpendingItem]) -> Void) {
        db.collection("trips").document(travelId)
            .collection("budgetCategories").document(categoryId)
            .collection("spendingItems").getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching spending items: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                let spendingItems = snapshot?.documents.compactMap { document in
                    try? document.data(as: SpendingItem.self)
                } ?? []
                
                completion(spendingItems)
            }
    }
    
    // MARK: - Fetch Budget Categories (Without Spending Items)
    /// Fetches budget categories for a specific trip with their IDs.
    func fetchBudgetCategories(tripId: String, completion: @escaping ([Category]) -> Void) {
        db.collection("trips").document(tripId).collection("budgetCategories")
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching budget categories: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                let categories = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Category.self)
                } ?? []
                
                completion(categories)
            }
    }
    
    // MARK: - Add New Spending Item
    /// Adds a new spending item to a specified category within a trip.
    func addSpendingItem(tripId: String, categoryId: String, spendingItem: SpendingItem, completion: @escaping (Bool) -> Void) {
        do {
            try db.collection("trips").document(tripId)
                .collection("budgetCategories").document(categoryId)
                .collection("spendingItems").addDocument(from: spendingItem)
            completion(true)
        } catch let error {
            print("Error adding spending item: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    // MARK: - Fetch Group Expenses
    /// Fetches group expenses for tracking balances within a trip.
    func fetchGroupExpenses(tripId: String, completion: @escaping ([GroupExpense]) -> Void) {
        db.collection("trips").document(tripId).collection("groupExpenses")
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching group expenses: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                let expenses = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: GroupExpense.self)
                } ?? []
                
                completion(expenses)
            }
    }
    
    // MARK: - Update Group Balance for Member
    /// Updates the group balance information for a specific member.
    func updateGroupBalance(tripId: String, groupExpense: GroupExpense, completion: @escaping (Bool) -> Void) {
        do {
            try db.collection("trips").document(tripId)
                .collection("groupExpenses").document(groupExpense.id)
                .setData(from: groupExpense)
            completion(true)
        } catch let error {
            print("Error updating group balance: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    // MARK: - Create New Budget Category
    /// Creates a new budget category for a trip.
    func createNewCategory(tripId: String, category: Category, completion: @escaping (Bool) -> Void) {
        do {
            try db.collection("trips").document(tripId)
                .collection("budgetCategories").addDocument(from: category)
            completion(true)
        } catch let error {
            print("Error creating new category: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    // MARK: - Delete a Budget Category and Its Spending Items
    /// Deletes a specified budget category and its associated spending items.
    func deleteCategoryWithSpendingItems(tripId: String, categoryId: String, completion: @escaping (Bool) -> Void) {
        let categoryRef = db.collection("trips").document(tripId).collection("budgetCategories").document(categoryId)
        
        categoryRef.collection("spendingItems").getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else {
                print("Error fetching spending items for deletion: \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
                return
            }
            
            let batch = self.db.batch()
            
            for document in documents {
                batch.deleteDocument(document.reference)
            }
            
            batch.deleteDocument(categoryRef)
            
            batch.commit { error in
                if let error = error {
                    print("Error deleting category and spending items: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Category and its spending items deleted successfully.")
                    completion(true)
                }
            }
        }
    }
    
    // MARK: - Update Spending Item
    /// Updates an existing spending item in a specific category.
    func updateSpendingItem(tripId: String, categoryId: String, spendingItemId: String, updatedItem: SpendingItem, completion: @escaping (Bool) -> Void) {
        do {
            try db.collection("trips").document(tripId)
                .collection("budgetCategories").document(categoryId)
                .collection("spendingItems").document(spendingItemId)
                .setData(from: updatedItem)
            completion(true)
        } catch let error {
            print("Error updating spending item: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    // MARK: - Delete Spending Item
    /// Deletes a specified spending item from a category within a trip.
    func deleteSpendingItem(tripId: String, categoryId: String, spendingItemId: String, completion: @escaping (Bool) -> Void) {
        db.collection("trips").document(tripId)
            .collection("budgetCategories").document(categoryId)
            .collection("spendingItems").document(spendingItemId).delete { error in
                if let error = error {
                    print("Error deleting spending item: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Spending item deleted successfully.")
                    completion(true)
                }
            }
    }
}
