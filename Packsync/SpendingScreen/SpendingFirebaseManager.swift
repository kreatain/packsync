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

    // MARK: - Fetch Expenses by IDs
    func fetchExpensesByIds(expenseIds: [String], completion: @escaping ([GroupExpense]) -> Void) {
        let expenseCollection = db.collection("groupExpenses")
        let dispatchGroup = DispatchGroup()
        var expenses: [GroupExpense] = []
        
        for expenseId in expenseIds {
            dispatchGroup.enter()
            expenseCollection.document(expenseId).getDocument { document, error in
                if let error = error {
                    print("Error fetching expense \(expenseId): \(error.localizedDescription)")
                    dispatchGroup.leave()
                    return
                }
                if let document = document, let expense = try? document.data(as: GroupExpense.self) {
                    expenses.append(expense)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(expenses)
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
    
    // MARK: - Fetch Group Expenses
    func fetchGroupExpenses(for travelId: String, completion: @escaping ([GroupExpense]) -> Void) {
        db.collection("travelPlans").document(travelId).collection("groupExpenses")
            .getDocuments { snapshot, error in
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

        let spendingItemsRef = db.collection("spendingItems")
        let dispatchGroup = DispatchGroup()
        var spendingItems: [SpendingItem] = []

        for categoryId in categoryIds {
            dispatchGroup.enter()
            print("Fetching category with ID: \(categoryId)")
            
            // Fetch the category document to retrieve the spending item IDs
            db.collection("categories").document(categoryId).getDocument { categorySnapshot, error in
                if let error = error {
                    print("Error fetching category \(categoryId): \(error.localizedDescription)")
                    dispatchGroup.leave()
                    return
                }
                
                guard let categoryData = categorySnapshot?.data(),
                      let spendingItemIds = categoryData["spendingItemIds"] as? [String] else {
                    print("Category \(categoryId) does not have spendingItemIds or failed to decode.")
                    dispatchGroup.leave()
                    return
                }
                
                print("Fetched \(spendingItemIds.count) spending item IDs for category \(categoryId).")

                // Fetch each spending item by ID
                for spendingItemId in spendingItemIds {
                    dispatchGroup.enter()
                    spendingItemsRef.document(spendingItemId).getDocument { document, error in
                        if let error = error {
                            print("Error fetching spending item \(spendingItemId): \(error.localizedDescription)")
                            dispatchGroup.leave()
                            return
                        }

                        if let document = document, let spendingItem = try? document.data(as: SpendingItem.self) {
                            spendingItems.append(spendingItem)
                            print("Fetched spending item with ID: \(spendingItemId), Amount: \(spendingItem.amount)")
                        } else {
                            print("Spending item \(spendingItemId) not found or failed to decode.")
                        }
                        dispatchGroup.leave()
                    }
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
        
        // Generate a new document ID for the spending item
        var spendingItemToAdd = spendingItem
        let newSpendingItemRef = spendingItemsRef.document()
        spendingItemToAdd.id = newSpendingItemRef.documentID // Assign the generated ID

        do {
            // Add the spending item to the spendingItems table
            try newSpendingItemRef.setData(from: spendingItemToAdd) { error in
                if let error = error {
                    print("Error adding spending item: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                // Update the category to include the new spending item ID
                categoryRef.updateData([
                    "spendingItemIds": FieldValue.arrayUnion([spendingItemToAdd.id])
                ]) { error in
                    if let error = error {
                        print("Error updating category with new spending item ID: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("Spending item added successfully and linked to category.")
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
    
    // MARK: - Add Group Expense
    func addGroupExpense(to travelId: String, groupExpense: GroupExpense, completion: @escaping (Bool) -> Void) {
        let groupExpensesRef = db.collection("groupExpenses")
        let travelRef = db.collection("travelPlans").document(travelId)

        // Step 1: Add the group expense to the GroupExpenses table
        var expenseToAdd = groupExpense
        let newExpenseRef = groupExpensesRef.document() // Generate a new document ID
        expenseToAdd.id = newExpenseRef.documentID // Assign Firestore-generated ID

        do {
            try newExpenseRef.setData(from: expenseToAdd) { error in
                if let error = error {
                    print("Error adding group expense to GroupExpenses table: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                // Step 2: Update the Travel table with the new group expense ID
                travelRef.updateData([
                    "expenseIds": FieldValue.arrayUnion([expenseToAdd.id])
                ]) { error in
                    if let error = error {
                        print("Error updating travel plan with new group expense ID: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("Group expense added successfully and linked to travel plan.")
                        completion(true)
                    }
                }
            }
        } catch {
            print("Error encoding group expense: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    // MARK: - Update Group Expense
    func updateGroupExpense(groupExpense: GroupExpense, completion: @escaping (Bool) -> Void) {
        let expenseRef = db.collection("groupExpenses").document(groupExpense.id)

        do {
            try expenseRef.setData(from: groupExpense) { error in
                if let error = error {
                    print("Error updating group expense: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Group expense updated successfully.")
                    completion(true)
                }
            }
        } catch {
            print("Error serializing group expense for update: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    // MARK: - Delete Group Expense
    func deleteGroupExpense(from travelId: String, expenseId: String, completion: @escaping (Bool) -> Void) {
        let expenseRef = db.collection("groupExpenses").document(expenseId)
        let travelRef = db.collection("travelPlans").document(travelId)

        let batch = db.batch()

        // Step 1: Delete the group expense from the GroupExpenses table
        batch.deleteDocument(expenseRef)

        // Step 2: Remove the expense ID from the Travel table
        batch.updateData([
            "expenseIds": FieldValue.arrayRemove([expenseId])
        ], forDocument: travelRef)

        batch.commit { error in
            if let error = error {
                print("Error deleting group expense: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Group expense deleted successfully.")
                completion(true)
            }
        }
    }
    
    // MARK: - Fetch Group Expenses by IDs
    func fetchGroupExpensesByIds(expenseIds: [String], completion: @escaping ([GroupExpense]) -> Void) {
        print("Starting fetchGroupExpensesByIds with expense IDs: \(expenseIds)")
        let groupExpensesRef = db.collection("groupExpenses")
        let dispatchGroup = DispatchGroup()
        var groupExpenses: [GroupExpense] = []

        for expenseId in expenseIds {
            print("Fetching group expense with ID: \(expenseId)")
            dispatchGroup.enter()
            groupExpensesRef.document(expenseId).getDocument { document, error in
                if let error = error {
                    print("Error fetching group expense \(expenseId): \(error.localizedDescription)")
                    dispatchGroup.leave()
                    return
                }
                if let document = document, let expense = try? document.data(as: GroupExpense.self) {
                    print("Successfully fetched group expense with ID: \(expenseId) - Amount Owed: \(expense.amountOwed), Amount Paid: \(expense.amountPaid)")
                    groupExpenses.append(expense)
                } else {
                    print("Group expense with ID: \(expenseId) not found or failed to decode.")
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            print("Finished fetching group expenses. Total fetched: \(groupExpenses.count)")
            for expense in groupExpenses {
                print(" - Group Expense ID: \(expense.id), Amount Owed: \(expense.amountOwed), Amount Paid: \(expense.amountPaid), Settled: \(expense.isSet)")
            }
            completion(groupExpenses)
        }
    }
    
    // MARK: - Fetch All Group Expenses for Travel Plan
    func fetchAllGroupExpenses(for travelId: String, completion: @escaping ([GroupExpense]) -> Void) {
        let travelRef = db.collection("travelPlans").document(travelId)

        travelRef.getDocument { document, error in
            if let error = error {
                print("Error fetching travel plan: \(error.localizedDescription)")
                completion([])
                return
            }
            guard let document = document, let travel = try? document.data(as: Travel.self) else {
                print("Failed to decode travel plan or travel plan does not exist.")
                completion([])
                return
            }

            // Use `fetchGroupExpensesByIds` to fetch group expenses by IDs
            self.fetchGroupExpensesByIds(expenseIds: travel.expenseIds) { groupExpenses in
                completion(groupExpenses)
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
