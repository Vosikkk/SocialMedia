//
//  MainView.swift
//  SocialMedia
//
//  Created by Саша Восколович on 09.02.2024.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        // MARK: - TableView With Recent Post's And Profile Tabs
        TabView {
            Text("Recent Post's")
                .tabItem {
                    Image(systemName: "rectangle.portrait.on.rectangle.portrait.angled")
                    Text("Post's")
                }
            ProfileView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Profile")
                }
        }
        // Changing Tab Label Tint to Black
        .tint(.black)
    }
}

#Preview {
    ContentView()
}
