//
//  SocialMediaApp.swift
//  SocialMedia
//
//  Created by Саша Восколович on 06.02.2024.
//

import SwiftUI
import Firebase

@main
struct SocialMediaApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
