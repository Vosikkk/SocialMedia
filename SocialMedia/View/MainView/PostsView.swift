//
//  PostsView.swift
//  SocialMedia
//
//  Created by Саша Восколович on 11.02.2024.
//

import SwiftUI

struct PostsView: View {
    
    @State private var createNewPost: Bool = false
    
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .hAlign(.center).vAlign(.center)
            .overlay(alignment: .bottomTrailing) {
                Button {
                    createNewPost.toggle()
                } label: {
                    Image(systemName: "plus")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(13)
                        .background(.black, in: Circle())
                }
                .padding(15)
            }
            .fullScreenCover(isPresented: $createNewPost) {
                CreateNewPost { post in
                    
                }
            }
    }
}

#Preview {
    PostsView()
}
