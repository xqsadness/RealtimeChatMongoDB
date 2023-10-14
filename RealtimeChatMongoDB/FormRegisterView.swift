//
//  RegisterView.swift
//  RealtimeChatMongoDB
//
//  Created by darktech4 on 30/05/2023.
//

import SwiftUI

struct FormRegisterView: View {
    @State var email: String = ""
    @State var emailForgot: String = ""
    @State var password: String = ""
    @State var comfirmPassword: String = ""
    @State var showError = false
    @State var errorMessage = ""
    @State var showResetPass = false
    @State var isSecure = true
    @Binding var selection:Int
    @Binding var isLoading:Bool
    
    var body: some View {
        VStack {
            VStack(spacing: 20) {
                Spacer()
                
                VStack{
                    HStack{
                        TextField("User Name", text: $email)
                            .font(Font.light(size: 15))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .autocapitalization(.none)
                    }
                    .frame(height: 20)
                    .cornerRadius(12)
                    .padding()
                }
                .background(Color.background2.opacity(0.2))
                .frame(maxWidth: .infinity)
                .cornerRadius(10)
                .mask(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color.gray.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 40)
//                .padding(.top, 100)
                
                
                VStack{
                    HStack{
                        HStack {
                            if isSecure {
                                SecureField("Password", text: $password, onCommit: {})
                                    .font(Font.light(size: 15))
                                    .foregroundColor(.black)
                            } else {
                                TextField("Password", text: $password, onEditingChanged: {_ in }, onCommit: { })
                                    .font(Font.light(size: 15))
                                    .foregroundColor(.black)
                            }
                            
                            Button(action: {
                                isSecure.toggle()
                            }) {
                                Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                                    .font(Font.light(size: 15))
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .frame(height: 20)
                    .cornerRadius(12)
                    .padding()
                }
                .background(Color.background2.opacity(0.2))
                .frame(maxWidth: .infinity)
                .cornerRadius(10)
                .mask(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color.gray.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 40)
                
                VStack{
                    HStack{
                        HStack {
                            if isSecure {
                                SecureField("Comfirm Password", text: $comfirmPassword, onCommit: {})
                                    .font(Font.light(size: 15))
                                    .foregroundColor(.black)
                            } else {
                                TextField("Comfirm Password", text: $comfirmPassword, onEditingChanged: {_ in }, onCommit: { })
                                    .font(Font.light(size: 15))
                                    .foregroundColor(.black)
                            }
                            
                            Button(action: {
                                isSecure.toggle()
                            }) {
                                Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                                    .font(Font.light(size: 15))
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .frame(height: 20)
                    .cornerRadius(12)
                    .padding()
                }
                .background(Color.background2.opacity(0.2))
                .frame(maxWidth: .infinity)
                .cornerRadius(10)
                .mask(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color.gray.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 40)
                
                Spacer()
            }
//            .frame(height: 500)
            
            Spacer()
            
            Button {
                resgister()
            } label: {
                Text("Register")
                    .font(.black(size: 20))
                    .foregroundColor(.background)
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(gradient: Gradient(colors: [Color(hex: "F90095"), Color(hex: "FF4848")]), startPoint: .bottomLeading, endPoint: .bottomTrailing))
            .cornerRadius(20)
            .padding(.horizontal, 40)
            .alert(errorMessage, isPresented: $showError) {}
        }
        .onAppear{
            email = ""
            emailForgot = ""
            password = ""
            comfirmPassword = ""
            showResetPass = false
        }
    }
    
    func resgister(){
        isLoading = true
        Task {
            do {
                if isValidEmail(email: email){
                    if comfirmPassword == password {
                        try await app.emailPasswordAuth.registerUser(email: email, password: password)
                        errorMessage = "Register sucsess"
                        showError = true
                        selection = 0
                        isLoading = false
                    }
                    else {
                        errorMessage = "Password must the confirm password"
                        showError = true
                        isLoading = false
                    }
                }else{
                    errorMessage = "Email invalidate"
                    showError = true
                    isLoading = false
                }
                
            } catch {
                setError(error)
            }
        }
    }
    
    func setError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
        isLoading = false
    }
    
    func isValidEmail(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

