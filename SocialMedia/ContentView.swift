//
//  ContentView.swift
//  SocialMedia
//
//  Created by Саша Восколович on 06.02.2024.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("log_status") var logStatus: Bool = false
    var body: some View {
        // MARK: - Redirecting User Based on log status
//        if logStatus {
//            MainView()
//        } else {
//            LoginView()
//        }
        
        CreateNewPost { _ in 
            
        }
    }
}

#Preview {
    ContentView()
}
