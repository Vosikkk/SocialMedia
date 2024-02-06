//
//  User.swift
//  SocialMedia
//
//  Created by Саша Восколович on 07.02.2024.
//

import Foundation
import FirebaseFirestoreSwift


struct User: Codable, Identifiable {
    
    @DocumentID var id: String?
    var username: String
    var userBio: String
    var userBioLink: String
    var userUID: String
    var userEmail: String
    var userProfileURL: URL
    
    
    enum CodingKeys: CodingKey {
        case id
        case username
        case userBio
        case userBioLink
        case userUID
        case userEmail
        case userProfileURL
    }
}
