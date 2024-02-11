//
//  PostsView.swift
//  SocialMedia
//
//  Created by Саша Восколович on 11.02.2024.
//

import SwiftUI

struct PostsView: View {
    
    @State private var createNewPost: Bool = false
    @State private var recentsPots: [Post] = []
    
    var body: some View {
        NavigationStack {
            ReusablePostsView(posts: $recentsPots)
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
           .toolbar {
               ToolbarItem(placement: .topBarTrailing) {
                   NavigationLink {
                       SearchUserView()
                   } label: {
                       Image(systemName: "magnifyingglass")
                           .tint(.black)
                           .scaleEffect(0.9)
                   }
               }
           }
           .navigationTitle("Post's")
        }
        .fullScreenCover(isPresented: $createNewPost) {
            CreateNewPost { post in
                /// - Adding Created post at the Top of the Recent Posts
                recentsPots.insert(post, at: 0)
            }
        }
    }
}

#Preview {
    PostsView()
}
