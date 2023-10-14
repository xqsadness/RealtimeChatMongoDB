//
//  FormLoginView.swift
//  RealtimeChatMongoDB
//
//  Created by darktech4 on 30/05/2023.
//

import SwiftUI
import RealmSwift

struct FormLoginView: View {
    @EnvironmentObject var state: AppState
    @State var email: String = "abc@gmail.com"
    @State var password: String = "123123"
    @State var showResetPass = false
    @State var isSecure = true
    @State var showError = false
    @State var errorMessage = ""
    @Binding var isLoading:Bool
    @Binding var userID: String?
    
    var body: some View {
        VStack {
            VStack(spacing: 20) {
                Spacer()
                
                VStack{
                    HStack{
                        TextField("Email", text: $email)
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
                
                Spacer()
            }
            
            Spacer()
            
            Button {
                userActionLogin()
            } label: {
                Text("Login")
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
//            email = ""
//            password = ""
            showResetPass = false
        }
    }
    
    func userActionLogin() {
        isLoading = true
        state.error = nil
        state.shouldIndicateActivity = true
        Task {
            do {
                if isValidEmail(email: email){
                    let user = try await app.login(credentials: .emailPassword(email: email, password: password))
                    userID = user.id
                    state.shouldIndicateActivity = false
                    isLoading = false
                }else{
                    errorMessage = "Email invalidate"
                    showError = true
                    isLoading = false
                }
            } catch {
                setError(error)
                state.error = error.localizedDescription
                state.shouldIndicateActivity = false
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

