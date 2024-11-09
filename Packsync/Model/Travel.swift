//
//  Travel.swift
//  Packsync
//
//  Created by Xi Jia on 11/8/24.

import Foundation

struct Travel: Codable {
    var creatorEmail: String
    var travelTitle: String
    var travelStartDate: String
    var travelEndDate: String
    var countryAndCity: String
    
    init(
        creatorEmail: String,
        travelTitle: String,
        travelStartDate: String,
        travelEndDate: String,
        countryAndCity: String
    ) {
        self.creatorEmail = creatorEmail
        self.travelTitle = travelTitle
        self.travelStartDate = travelStartDate
        self.travelEndDate = travelEndDate
        self.countryAndCity = countryAndCity
    }
}
