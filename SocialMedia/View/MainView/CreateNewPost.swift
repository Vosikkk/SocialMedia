//
//  CreateNewPost.swift
//  SocialMedia
//
//  Created by Саша Восколович on 10.02.2024.
//

import SwiftUI
import PhotosUI
import Firebase
import FirebaseStorage

struct CreateNewPost: View {
    /// -  Callback
    var onPost: (Post) -> ()
    
    /// - Post properties
    @State private var postText: String = ""
    @State private var postImageData: Data?
    
    /// - Strored User Data From Userefaults(AppStorage)
    @AppStorage("user_profile_url") private var profileURL: URL?
    @AppStorage("user_name") private var userName: String = ""
    @AppStorage("user_UID") private var userUID: String = ""
    
    /// - View Properties
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var photoItem: PhotosPickerItem?
    @FocusState private var showKeyBoard: Bool
    
    var body: some View {
        VStack {
            HStack {
                Menu {
                    Button("Cancel", role: .destructive) {
                        dismiss()
                    }
                } label: {
                    Text("Cancel")
                        .font(.callout)
                        .foregroundStyle(.black)
                }
                .hAlign(.leading)
                
                Button(action: createPost) {
                    Text("Post")
                        .font(.callout)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 6)
                        .background(.black, in: Capsule())
                    
                }
                .disableWithOpacity(postText == "")
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background {
                Rectangle()
                    .fill(.gray.opacity(0.05))
                    .ignoresSafeArea()
            }
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 15) {
                    TextField("What's happening?", text: $postText, axis: .vertical)
                        .focused($showKeyBoard)
                    
                    if let postImageData, let image = UIImage(data: postImageData) {
                        GeometryReader {
                            let size = $0.size
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: size.width, height: size.height)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            
                            /// Delete Button
                                .overlay(alignment: .topTrailing) {
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.25)) {
                                            self.postImageData = nil
                                        }
                                    } label: {
                                        Image(systemName: "trash")
                                            .fontWeight(.bold)
                                            .tint(.red)
                                    }
                                    .padding(10)
                                }
                        }
                        .clipped()
                        .frame(height: 220)
                    }
                }
                .padding(15)
            }
            Divider()
            
            HStack {
                Button {
                    showImagePicker.toggle()
                } label: {
                    Image(systemName: "photo.on.rectangle")
                        .font(.title3)
                }
                
                .hAlign(.leading)
                
                Button("Done") {
                    showKeyBoard = false
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .foregroundStyle(.black)
        }
        .vAlign(.top)
        .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
        .onChange(of: photoItem) { oldValue, newValue in
            if let newValue {
                Task {
                    if let rowImageData = try? await newValue.loadTransferable(type: Data.self), 
                        let image = UIImage(data: rowImageData), 
                        let compressedImageData = image.jpegData(compressionQuality: 0.5) {
                        /// UI must be done on Main Thread
                        await MainActor.run {
                            postImageData = compressedImageData
                            photoItem = nil
                        }
                    }
                }
            }
        }
        .alert(errorMessage, isPresented: $showError) {
            
        }
        /// - Loading View
        .overlay {
            LoadingView(show: $isLoading)
        }
    }
    
    // MARK: - Post Content To Firebase
    
    func createPost() {
        isLoading = true
        showKeyBoard = false
        Task {
            do {
                guard let profileURL = profileURL else { return }
                /// Step 1: Uploading Image if Any
                let imageReferanceID = "\(userUID)\(Date())"
                let storageRef = Storage.storage().reference().child("Post_Images").child(imageReferanceID)
                if let postImageData {
                    let _ = try await storageRef.putDataAsync(postImageData)
                    let downloadURL = try await storageRef.downloadURL()
                    
                    /// Step 3: Create Post Object With Image Id and URL
                    let post = Post(text: postText, imageURL: downloadURL, imageReferenceID: imageReferanceID, userName: userName, userUID: userUID, userProfileURL: profileURL)
                    try await createDocumentAtFirebase(post)
                    
                } else {
                    /// Step 2: Directly Post Text Data to Firebase (Since tehre is no Image  Present)
                    let post = Post(text: postText, userName: userName, userUID: userUID, userProfileURL: profileURL)
                    try await createDocumentAtFirebase(post)
                }
            } catch {
                await setError(error)
            }
        }
    }
    
    func createDocumentAtFirebase(_ post: Post) async throws {
        /// Writing Doument to Firebase Firestore
        let _ = try Firestore.firestore().collection("Posts").addDocument(from: post) { error in
            if error == nil {
                /// Post Successfully Stored at Firebase
                isLoading = false
                onPost(post)
                dismiss()
            }
        }
    }
    
    // MARK: Displaying Errors as Alert
    
    func setError(_ error: Error) async {
        await MainActor.run {
            errorMessage = error.localizedDescription
            showError.toggle()
        }
    }
}

#Preview {
    CreateNewPost { _ in
        
    }
}
