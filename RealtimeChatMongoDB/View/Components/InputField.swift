//
//  InputField.swift
//  RealtimeChatMongoDB
//
//  Created by darktech4 on 31/05/2023.
//

import SwiftUI

struct InputField: View {
    
    let title: String
    @Binding private(set) var text: String
    var showingSecureField = false
    
    private enum Dimensions {
        static let noSpacing: CGFloat = 0
        static let bottomPadding: CGFloat = 16
        static let iconSize: CGFloat = 20
    }
    
    var body: some View {
        VStack(spacing: Dimensions.noSpacing) {
            CaptionLabel(title: title)
            HStack(spacing: Dimensions.noSpacing) {
                if showingSecureField {
                    SecureField("", text: $text)
                        .padding(.bottom, Dimensions.bottomPadding)
                        .foregroundColor(.text)
                        .font(.body)
                } else {
                    VStack{
                        TextField("", text: $text)
                            .padding(5)
                            .foregroundColor(.text)
                            .font(.body)
                            .background(
                                Rectangle()
                                    .foregroundColor(Color.text2)
                            )
                            .cornerRadius(10)
                    }
                }
            }
        }
    }
}
