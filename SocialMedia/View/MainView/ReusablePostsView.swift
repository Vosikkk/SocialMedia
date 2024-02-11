//
//  ReusablePostsView.swift
//  SocialMedia
//
//  Created by Саша Восколович on 11.02.2024.
//

import SwiftUI
import Firebase


struct ReusablePostsView: View {
    
    @Binding var posts: [Post]
    
    /// - View Properties
    
    @State var isFetching: Bool = true
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                if isFetching {
                    ProgressView()
                        .padding(.top, 30)
                } else {
                    if posts.isEmpty {
                        /// - No Posts Found on Firestore
                        Text("No Post's Found")
                            .font(.caption)
                            .foregroundStyle(.gray)
                            .padding(.top, 30)
                    } else {
                        /// - Displaying Post's
                        Posts()
                    }
                }
            }
            .padding(15)
        }
        .refreshable {
            /// - Scroll To Refresh
            isFetching = true
            posts = []
            await fetchPosts()
        }
        
        .task {
            /// - Fetching For One Time
            guard posts.isEmpty else { return }
            await fetchPosts()
        }
    }
    
    /// - Displaying Fetched Post's
    @ViewBuilder
    func Posts() -> some View {
        ForEach(posts) { post in
            PostCardView(post: post) { updatedPost in
                
            } onDelete: {
                
            }

        }
    }
    
    /// Fetching Post's
    func fetchPosts() async {
        do {
            var query: Query!
            query = Firestore.firestore().collection("Posts")
                .order(by: "publishedDate", descending: true)
                .limit(to: 20)
            let docs = try await query.getDocuments()
            let fetchedPosts = docs.documents.compactMap { doc -> Post? in
                try? doc.data(as: Post.self)
            }
            await MainActor.run {
                posts = fetchedPosts
                isFetching = false
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

#Preview {
   ContentView()
}
