//
//  LoginView.swift
//  RealtimeChatMongoDB
//
//  Created by Darktech on 5/29/23.
//

import SwiftUI

struct LoginView: View {
    @State var showResetPass = false
    @State var selection = 0
    @State var isLoading = false
    @Binding var userID: String?

    var body: some View {
        VStack {
            Text("Hey, \nLogin Now")
                .font(.black(size: 46))
                .foregroundColor(.text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 40)
                .padding(.top, 100)
            
            if selection == 0 {
                HStack {
                    Text("If you are new /")
                        .font(.light(size: 20))
                        .foregroundColor(.text.opacity(0.7))
                    
                    Text("Create New")
                        .font(.light(size: 20))
                        .foregroundColor(.text)
                        .onTapGesture {
                            showResetPass = false
                            withAnimation {
                                selection = 1
                            }
                        }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 40)
                .padding(.top, 5)
            }
            else {
                HStack {
                    Text("If you have account /")
                        .font(.light(size: 20))
                        .foregroundColor(.text.opacity(0.7))
                    
                    Text("Login Now")
                        .font(.light(size: 20))
                        .foregroundColor(.text)
                        .onTapGesture {
                            showResetPass = false
                            withAnimation {
                                selection = 0
                            }
                        }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 40)
                .padding(.top, 5)
            }
            
            if selection == 0{
                FormLoginView(isLoading: $isLoading,userID: $userID)
            }
            else {
                FormRegisterView(selection: $selection, isLoading: $isLoading)
            }
            
            Spacer()
        }
        .overlay(content: {
            LoadingView(show: $isLoading)
        })
    }
}
