//
//  Billboard.swift
//  Packsync
//
//  Created by 许多 on 11/16/24.
//
import Foundation


struct Billboard: Codable, Identifiable {
    var id: String? // Firestore Document ID
    var travelId: String // The ID of the associated travel
    var type: String? // // Type of content (notice, vote, or photo)
    var content: String? // Content for notice
    var title: String? // Title for vote
    var choices: [String]? // Choices for vote
    var votes: [String: Int]? // Dictionary of vote counts for each choice
    var photoUrl: String? // URL for the photo
    var createdAt: Date // Timestamp of creation
    var authorId: String // ID of the author
    

    // Default initializer
    init(
        id: String? = nil,
        travelId: String,
        type: String? = nil,
        content: String? = nil,
        title: String? = nil,
        choices: [String]? = nil,
        votes: [String: Int]? = nil,
        photoUrl: String? = nil,
        createdAt: Date = Date(),
        authorId: String
    
    ) {
        self.id = id
        self.travelId = travelId
        self.type = type
        self.content = content
        self.title = title
        self.choices = choices
        self.votes = votes
        self.photoUrl = photoUrl
        self.createdAt = createdAt
        self.authorId = authorId
        
    }
}
