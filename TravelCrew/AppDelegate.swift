//
//  AppDelegate.swift
//  Packsync
//
//  Created by 许多 on 10/24/24.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
            _ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {
            // Configure Firebase
            FirebaseApp.configure()
            configureFirestore()
            
            // Clear the active travel plan if no user is logged in
            if Auth.auth().currentUser == nil {
                TravelPlanManager.shared.clearActiveTravelPlan()
            }
            
            return true
        }
    
    // MARK: - Configure Firestore
    private func configureFirestore() {
        let db = Firestore.firestore()
        
        // Clear existing cached data asynchronously
        db.clearPersistence { error in
            if let error = error {
                print("Error clearing Firestore persistence: \(error.localizedDescription)")
            } else {
                print("Firestore persistence cleared successfully.")
            }
        }
        
        // Set Firestore cache settings
        let cacheSettings = MemoryCacheSettings() // Use in-memory cache
        let settings = FirestoreSettings()
        settings.cacheSettings = cacheSettings // Apply memory cache settings
        
        db.settings = settings
        
        print("Firestore cache settings applied: In-memory caching enabled.")
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {
        // Called when the user discards a scene session.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
