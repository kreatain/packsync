//
//  User.swift
//  Packsync
//
//  Created by Xi Jia on 11/8/24.

import Foundation

struct User: Codable {
    let email: String
    let password: String
    var displayName: String?
}
