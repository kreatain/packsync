////
////  SceneDelegate.swift
////  Packsync
////
////  Created by 许多 on 10/24/24.
////
//
//import UIKit
//
//class SceneDelegate: UIResponder, UIWindowSceneDelegate {
//
//    var window: UIWindow?
//
//
//    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
//        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
//        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
//        guard let _ = (scene as? UIWindowScene) else { return }
//    }
//
//    func sceneDidDisconnect(_ scene: UIScene) {
//        // Called as the scene is being released by the system.
//        // This occurs shortly after the scene enters the background, or when its session is discarded.
//        // Release any resources associated with this scene that can be re-created the next time the scene connects.
//        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
//    }
//
//    func sceneDidBecomeActive(_ scene: UIScene) {
//        // Called when the scene has moved from an inactive state to an active state.
//        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
//    }
//
//    func sceneWillResignActive(_ scene: UIScene) {
//        // Called when the scene will move from an active state to an inactive state.
//        // This may occur due to temporary interruptions (ex. an incoming phone call).
//    }
//
//    func sceneWillEnterForeground(_ scene: UIScene) {
//        // Called as the scene transitions from the background to the foreground.
//        // Use this method to undo the changes made on entering the background.
//    }
//
//    func sceneDidEnterBackground(_ scene: UIScene) {
//        // Called as the scene transitions from the foreground to the background.
//        // Use this method to save data, release shared resources, and store enough scene-specific state information
//        // to restore the scene back to its current state.
//    }
//
//
//}
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.makeKeyAndVisible()
        
        // Create view controllers for each screen
        let travelsVC = TravelListViewController()
        let packingVC = PackingListViewController()
        let spendingVC = SpendingViewController()
        let billboardVC = BillboardViewController()
        let profileVC = ProfileViewController()
        
        // Embed each view controller in a navigation controller
        let travelsNavController = UINavigationController(rootViewController: travelsVC)
        let packingNavController = UINavigationController(rootViewController: packingVC)
        let spendingNavController = UINavigationController(rootViewController: spendingVC)
        let billboardNavController = UINavigationController(rootViewController: billboardVC)
        let profileNavController = UINavigationController(rootViewController: profileVC)
        
        // Set up tab bar items
        travelsNavController.tabBarItem = UITabBarItem(title: "Travels", image: UIImage(systemName: "airplane"), tag: 0)
        packingNavController.tabBarItem = UITabBarItem(title: "Packing", image: UIImage(systemName: "bag"), tag: 1)
        spendingNavController.tabBarItem = UITabBarItem(title: "Spending", image: UIImage(systemName: "dollarsign.circle"), tag: 2)
        billboardNavController.tabBarItem = UITabBarItem(title: "Billboard", image: UIImage(systemName: "signpost.right"), tag: 3)
        profileNavController.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 4)
        
        // Create tab bar controller and set view controllers
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [travelsNavController, packingNavController, spendingNavController, billboardNavController, profileNavController]
        
        // Set tab bar controller as root view controller
        window?.rootViewController = tabBarController
    }
}
