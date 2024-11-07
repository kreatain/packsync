//
//  User.swift
//  Packsync
//
//  Created by 许多 on 10/24/24.
//  Defines user-related data (name, email, etc.).
import Foundation

struct User: Codable {
    let email: String
    let password: String
    var displayName: String?
}

