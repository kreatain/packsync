//
//  SceneDelegate.swift
//  Packsync
//
//  Created by 许多 on 10/24/24.
//

import UIKit


class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.makeKeyAndVisible()
        
        // Create view controllers for each screen
        let travelsVC = TravelViewController()
        let packingVC = PackinListViewController()
        let spendingVC = SpendingViewController()
        let billboardVC = BillboardViewController()
        let profileVC = ProfileViewController()
        
        // Embed each view controller in a navigation controller
        let travelsNavController = UINavigationController(rootViewController: travelsVC)
        let packingNavController = UINavigationController(rootViewController: packingVC)
        let spendingNavController = UINavigationController(rootViewController: spendingVC)
        let billboardNavController = UINavigationController(rootViewController: billboardVC)
        let profileNavController = UINavigationController(rootViewController: profileVC)
        
        // Create a custom image configuration for smaller icons
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .default)
        
        // Set up tab bar items with resized icons
        
        travelsNavController.tabBarItem = UITabBarItem(title: "Travels", image: UIImage(systemName: "airplane", withConfiguration: iconConfig), tag: 0)
        packingNavController.tabBarItem = UITabBarItem(title: "Packing", image: UIImage(systemName: "bag", withConfiguration: iconConfig), tag: 1)
        spendingNavController.tabBarItem = UITabBarItem(title: "Spending", image: UIImage(systemName: "dollarsign.circle", withConfiguration: iconConfig), tag: 2)
        billboardNavController.tabBarItem = UITabBarItem(title: "Billboard", image: UIImage(systemName: "signpost.right", withConfiguration: iconConfig), tag: 3)
        profileNavController.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person", withConfiguration: iconConfig), tag: 5)
        
        // Create tab bar controller and set view controllers
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [ travelsNavController, packingNavController, spendingNavController, billboardNavController, profileNavController,]
        
        // Customize tab bar appearance
        UITabBar.appearance().tintColor = .systemBlue
        UITabBar.appearance().unselectedItemTintColor = .gray
        
        // Adjust tab bar item insets to allow more space
        UITabBar.appearance().itemPositioning = .fill
        UITabBar.appearance().itemWidth = 50 // Adjust this value as needed
        UITabBar.appearance().itemSpacing = 4
        
        // Set tab bar controller as root view controller
        window?.rootViewController = tabBarController
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let navController = viewController as? UINavigationController,
           let packingVC = navController.topViewController as? PackinListViewController {
            packingVC.updateUI()
        }
        return true
    }
}
