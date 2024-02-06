//
//  LoginView.swift
//  SocialMedia
//
//  Created by Саша Восколович on 06.02.2024.
//

import SwiftUI
import PhotosUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct LoginView: View {
    
    // MARK: - User Detail
    @State var emailID: String = ""
    @State var password: String = ""
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @State var isLoading: Bool = false
    
    // MARK: - UserDefaults
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_prrofile_url") var profileURL: URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    
    // MARK: - User Properties
    
    @State var createAccount: Bool = false
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Lets Sign you in")
                .font(.largeTitle.bold())
                .hAlign(.leading)
            Text("Welcome Back,\nYou have been missed")
                .font(.title3)
                .hAlign(.leading)
            VStack {
                emailField
                passwordField
                resetPasswordButton
                loginButton
            }
            // MARK: - Register Button
            HStack {
                Text("Already have an account?")
                    .foregroundStyle(.gray)
                registerButton
            }
            .font(.callout)
            .vAlign(.bottom)
       }
        .vAlign(.top)
        .overlay {
            LoadingView(show: $isLoading)
        }
        .padding(15)
        
        // MARK: - Register View VIA Sheets
        .fullScreenCover(isPresented: $createAccount, content: {
            RegisterView()
        })
        
        // MARK: - Displaying Alert
        .alert(errorMessage, isPresented: $showError) {
            
        }
        
    }
    
    private var passwordField: some View {
        SecureField("Password", text: $password)
            .textContentType(.emailAddress)
            .border(1, .gray.opacity(0.5))
    }
   
    private var emailField: some View {
        TextField("Email", text: $emailID)
            .textContentType(.emailAddress)
            .border(1, .gray.opacity(0.5))
            .padding(.top, 25)
    }
    
    private var resetPasswordButton: some View {
        Button("Reset password?", action: resetPassword)
            .font(.callout)
            .fontWeight(.medium)
            .tint(.black)
            .hAlign(.trailing)
    }
    
    private var loginButton: some View {
        Button(action: loginUser) {
            // MARK: - Login Button
            Text("Sign in")
                .foregroundStyle(.white)
                .hAlign(.center)
                .fillView(.black)
        }
        .padding(.top, 10)
    }
    
    private var registerButton: some View {
        Button("Register Now") {
            createAccount.toggle()
        }
        .fontWeight(.bold)
        .foregroundStyle(.black)
    }
    
    func loginUser() {
        isLoading = true
        Task {
            do {
                // With the help of Swift Concurrency Auth can be done with single line
                try await Auth.auth().signIn(withEmail: emailID, password: password)
                print("User Found")
                try await fetchUser()
            } catch {
                await setError(error)
            }
        }
    }
    
    // MARK: - Displaying Errors VIA Alert
    
    func setError(_ error: Error) async {
        await MainActor.run {
            errorMessage = error.localizedDescription
            showError.toggle()
            isLoading = false
        }
    }
    
    // MARK: - If user if found then Fetching user data from firestore
    
    func fetchUser() async throws {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let user = try await Firestore.firestore().collection("Users").document(userID).getDocument(as: User.self)
        // MARK: - UI Updating Must be run on Main Thread
        await MainActor.run {
            // Setting UserDefaults data and Changing App's Auth Status
            userUID = userID
            userNameStored = user.username
            profileURL = user.userProfileURL
            logStatus = true 
        }
    }
    
    func resetPassword() {
        Task {
            do {
                // With the help of Swift Concurrency Auth can be done with single line
                try await Auth.auth().sendPasswordReset(withEmail: emailID)
                print("Link Sent")
            } catch {
                await setError(error)
            }
        }
    }
}

#Preview {
    LoginView()
}


// MARK: - Register View

struct RegisterView: View {
    
    @State var emailID: String = ""
    @State var password: String = ""
    @State var userName: String = ""
    @State var userBio: String = ""
    @State var userBioLink: String = ""
    @State var userProfilePicData: Data?
    @State var errorMessage: String = ""
    @State var showError: Bool = false
    @State var isLoading: Bool = false
    
    // MARK: - View Properties
    
    @Environment(\.dismiss) var dismiss
    
    @State var showImagePicker: Bool = false
    @State var photoItem: PhotosPickerItem?
    
    // MARK: - UserDefaults
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_prrofile_url") var profileURL: URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Lets Register\nAccount")
                .font(.largeTitle.bold())
                .hAlign(.leading)
            Text("Hello user, have a wonderful journey")
                .font(.title3)
                .hAlign(.leading)
            
            // MARK: - For smaller size optimazation
            ViewThatFits {
                ScrollView(.vertical, showsIndicators: false) {
                    HelperView()
                }
                HelperView()
            }
            
            // MARK: - Register Button
            HStack {
                Text("Already have an account?")
                    .foregroundStyle(.gray)
                loginButton
            }
            .font(.callout)
            .vAlign(.bottom)
        }
        .vAlign(.top)
        .padding(15)
        .overlay {
            LoadingView(show: $isLoading)
        }
        .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
        .onChange(of: photoItem) { _ , newValue in
            
            // MARK: - Extracting UIImage From PhotoItem
            if let newValue {
                Task {
                    do {
                        guard let imageData = try await newValue.loadTransferable(type: Data.self) else { return }
                        // MARK: - UI Must Be Updated on Main Thread
                        await MainActor.run {
                            userProfilePicData = imageData
                        }
                    } catch {
                        
                    }
                }
            }
        }
        
        // MARK: - Displaying Alert
        
        .alert(errorMessage, isPresented: $showError) {
            
        }
    }
    
    
    private var bioLinkTextField: some View {
        TextField("Bio Link (Optional)", text: $userBioLink)
            .textContentType(.emailAddress)
            .border(1, .gray.opacity(0.5))
    }
    
    
    private var aboutYouTextField: some View {
        TextField("About You", text: $userBio, axis: .vertical)
            .frame(minHeight: 100, alignment: .top)
            .textContentType(.emailAddress)
            .border(1, .gray.opacity(0.5))
    }
    
    
    private var loginButton: some View {
        Button("Login Now") {
            dismiss()
        }
        .fontWeight(.bold)
        .foregroundStyle(.black)
    }
    
    private var signUpButton: some View {
        Button(action: registerUser) {
            // MARK: - Login Button
            Text("Sign up")
                .foregroundStyle(.white)
                .hAlign(.center)
                .fillView(.black)
        }
        .disableWithOpacity(userName == "" || userBio == "" || emailID == "" || password == "" || userProfilePicData == nil)
        .padding(.top, 10)
        
    }
    
    private var passwordTextField: some View {
        SecureField("Password", text: $password)
            .textContentType(.emailAddress)
            .border(1, .gray.opacity(0.5))
    }
    
    private var emailTextField: some View {
        TextField("Email", text: $emailID)
            .textContentType(.emailAddress)
            .border(1, .gray.opacity(0.5))
    }
    
    private var userNameTextField: some View {
        TextField("Username", text: $userName)
            .textContentType(.emailAddress)
            .border(1, .gray.opacity(0.5))
            
    }
    
    private var imageProfile: some View {
        ZStack {
            if let userProfilePicData, let image = UIImage(data: userProfilePicData) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image("NullProfile")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
        .frame(width: 85, height: 85)
        .clipShape(Circle())
        .contentShape(Circle())
        .onTapGesture {
            showImagePicker.toggle()
        }
        .padding(.top, 25)
    }
    
    
    @ViewBuilder
    func HelperView() -> some View {
        VStack(spacing: 12) {
            imageProfile
            userNameTextField
            emailTextField
            passwordTextField
            aboutYouTextField
            bioLinkTextField
            signUpButton
        }
    }
    
    func registerUser() {
        isLoading = true
        Task {
            do {
                
                // Step 1: Creating Firebase Account
                try await Auth.auth().createUser(withEmail: emailID, password: password)
                // Step 2: Uploading Profile Photo Info Firebase Storage
                guard let userUID = Auth.auth().currentUser?.uid else { return }
                guard let imageData = userProfilePicData else { return }
                let storageRef = Storage.storage().reference().child("Profile_Images").child(userUID)
                let _ = try await storageRef.putDataAsync(imageData)
                // Step 3: Downloading Photo URL
                let downloadURL = try await storageRef.downloadURL()
                // Step 4: Creating a User Firestore Object 
                let user = User(
                    username: userName,
                    userBio: userBio,
                    userBioLink: userBioLink,
                    userUID: userUID,
                    userEmail: emailID,
                    userProfileURL: downloadURL
                )
                // Step 5: Saving user doc into Firestore Database
                
                let _ = try Firestore.firestore().collection("Users").document(userUID).setData(from: user) { error in
                    if error == nil {
                        // MARK: - Print Saved Successfully
                        print("Saved Successfully")
                        userNameStored = userName
                        self.userUID = userUID
                        profileURL = downloadURL
                        logStatus = true
                    }
                }
                
            } catch {
                // MARK: Deleting Created Account in Case Of Failure
                try await Auth.auth().currentUser?.delete()
                await setError(error)
            }
        }
    }
    
    // MARK: - Displaying Errors VIA Alert
    
    func setError(_ error: Error) async {
        await MainActor.run {
            errorMessage = error.localizedDescription
            showError.toggle()
            isLoading = false
        }
    }
}



// MARK: - View Extensions For UI Building

extension View {
    
    // MARK: - Disabling with Opacity
    
    func disableWithOpacity(_ condition: Bool) -> some View {
        self
            .disabled(condition)
            .opacity(condition ? 0.6 : 1)
    }
    
    
    
    func hAlign(_ alignment: Alignment) -> some View {
        self
            .frame(maxWidth: .infinity, alignment: alignment)
    }
    
    func vAlign(_ alignment: Alignment) -> some View {
        self
            .frame(maxHeight: .infinity, alignment: alignment)
    }
    
    // MARK: - Custom Border View With Padding
    
    func border(_ width: CGFloat, _ color: Color) -> some View {
        self
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(color, lineWidth: width)
            }
    }
    
    
    // MARK: - Custom Fill View With Padding
    func fillView(_ color: Color) -> some View {
        self
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(color)
            }
    }
}
