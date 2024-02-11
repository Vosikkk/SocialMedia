//
//  PostCardView.swift
//  SocialMedia
//
//  Created by Саша Восколович on 11.02.2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct PostCardView: View {
    
    var post: Post
    
    /// - CallBacks
    var onUpdate: (Post) -> ()
    var onDelete: () -> ()
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            WebImage(url: post.userProfileURL)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 35, height: 35)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 6) {
                Text(post.userName)
                    .font(.callout)
                    .fontWeight(.semibold)
                Text(post.publishedDate.formatted(date: .numeric, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.gray)
                Text(post.text)
                    .textSelection(.enabled)
                    .padding(.vertical, 8)
                
                
                /// Post Image if Any
                if let postImageURL = post.imageURL {
                    GeometryReader {
                        let size = $0.size
                        WebImage(url: postImageURL)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .frame(height: 200)
                }
                PostInteraction()
            }
        }
        .hAlign(.leading)
    }
    
    // MARK: - Like/Dislike Imteraction
    
    @ViewBuilder
    func PostInteraction() -> some View {
        HStack(spacing: 6) {
            Button {
                
            } label: {
                Image(systemName: "hand.thumbsup")
            }
            
            Text("\(post.likedIDs.count)")
                .font(.caption)
                .foregroundStyle(.gray)
            
            Button {
                
            } label: {
                Image(systemName: "hand.thumbsdown")
            }
            
            Text("\(post.dislikedIDs.count)")
                .font(.caption)
                .foregroundStyle(.gray)
        }
        .foregroundStyle(.black)
        .padding(.vertical, 8)
    }
}

