//
//  LoginView.swift
//  SocialMedia
//
//  Created by Саша Восколович on 06.02.2024.
//

import SwiftUI

struct LoginView: View {
    
    // MARK: - User Detail
    @State var emailID: String = ""
    @State var password: String = ""
   
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
                TextField("Email", text: $emailID)
                    .textContentType(.emailAddress)
                    .border(1, .gray.opacity(0.5))
                    .padding(.top, 25)
                
                SecureField("Password", text: $password)
                    .textContentType(.emailAddress)
                    .border(1, .gray.opacity(0.5))
                
                Button("Reset password?", action: {})
                    .font(.callout)
                    .fontWeight(.medium)
                    .tint(.black)
                    .hAlign(.trailing)
                
                Button {
                    
                } label: {
                    // MARK: - Login Button
                    Text("Sign in")
                        .foregroundStyle(.white)
                        .hAlign(.center)
                        .fillView(.black)
                }
                .padding(.top, 10)
            }
            // MARK: - Register Button
            HStack {
                Text("Already have an account?")
                    .foregroundStyle(.gray)
                Button("Register Now") {
                    createAccount.toggle()
                }
                .fontWeight(.bold)
                .foregroundStyle(.black)
            }
            .font(.callout)
            .vAlign(.bottom)
       }
        .vAlign(.top)
        .padding(15)
        
        // MARK: - Register View VIA Sheets
        .fullScreenCover(isPresented: $createAccount, content: {
            RegisterView()
        })
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
    // MARK: - View Properties
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Lets Register\nAccount")
                .font(.largeTitle.bold())
                .hAlign(.leading)
            Text("Hello user, have a wonderful journey")
                .font(.title3)
                .hAlign(.leading)
            VStack {
                TextField("Username", text: $userName)
                    .textContentType(.emailAddress)
                    .border(1, .gray.opacity(0.5))
                    .padding(.top, 25)
                
                TextField("Email", text: $emailID)
                    .textContentType(.emailAddress)
                    .border(1, .gray.opacity(0.5))
                   
                
                SecureField("Password", text: $password)
                    .textContentType(.emailAddress)
                    .border(1, .gray.opacity(0.5))
                
                Button {
                    
                } label: {
                    // MARK: - Login Button
                    Text("Sign up")
                        .foregroundStyle(.white)
                        .hAlign(.center)
                        .fillView(.black)
                }
                .padding(.top, 10)
            }
            // MARK: - Register Button
            HStack {
                Text("Already have an account?")
                    .foregroundStyle(.gray)
                Button("Login Now") {
                    dismiss()
                }
                .fontWeight(.bold)
                .foregroundStyle(.black)
            }
            .font(.callout)
            .vAlign(.bottom)
        }
        .vAlign(.top)
        .padding(15)
    }
}



// MARK: - View Extensions For UI Building

extension View {
    
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
