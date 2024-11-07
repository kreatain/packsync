//
//  UserManager.swift
//  Packsync
//
//  Created by Jessica on 10/27/24.
//
import Foundation

class UserManager {
    static let shared = UserManager()
    private let userKey = "loggedInUser"

    func signUp(email: String, password: String, displayName: String?) -> Bool {
        let user = User(email: email, password: password, displayName: displayName)
        if let encodedUser = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encodedUser, forKey: userKey)
            return true
        }
        return false
    }

    func login(email: String, password: String) -> Bool {
        guard let savedUserData = UserDefaults.standard.data(forKey: userKey),
              let savedUser = try? JSONDecoder().decode(User.self, from: savedUserData) else {
            return false
        }
        return savedUser.email == email && savedUser.password == password
    }

    func getCurrentUser() -> User? {
        if let savedUserData = UserDefaults.standard.data(forKey: userKey),
           let savedUser = try? JSONDecoder().decode(User.self, from: savedUserData) {
            return savedUser
        }
        return nil
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: userKey)
    }
}
