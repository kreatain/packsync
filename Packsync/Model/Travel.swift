//
//  Travel.swift
//  Packsync
//
//  Created by 许多 on 10/24/24.
//  Defines properties for travel, such as the trip name, start/end date, and country/city.

//import Foundation
//
//struct Travel: Codable {
//    var creatorEmail: String
//    var travelTitle: String
//    var travelStartDate: String
//    var travelEndDate: String
//    var countryAndCity: String
//    
//    init(creatorEmail: String, travelTitle: String, travelStartDate: String, travelEndDate: String, countryAndCity: String) {
//        self.creatorEmail = creatorEmail
//        self.travelTitle = travelTitle
//        self.travelStartDate = travelStartDate
//        self.travelEndDate = travelEndDate
//        self.countryAndCity = countryAndCity
//    }
//}
import Foundation

struct Travel: Codable {
//    var creatorEmail: String
    var travelTitle: String
    var travelStartDate: String
    var travelEndDate: String
    var countryAndCity: String
    
    init(
//        creatorEmail: String,
        travelTitle: String, travelStartDate: String, travelEndDate: String, countryAndCity: String) {
//        self.creatorEmail = creatorEmail
        self.travelTitle = travelTitle
        self.travelStartDate = travelStartDate
        self.travelEndDate = travelEndDate
        self.countryAndCity = countryAndCity
    }
}
