//
//  LoginView.swift
//  SocialMedia
//
//  Created by Саша Восколович on 06.02.2024.
//

import SwiftUI
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
    @AppStorage("user_profile_url") var profileURL: URL?
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
        closeKeyboard()
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

