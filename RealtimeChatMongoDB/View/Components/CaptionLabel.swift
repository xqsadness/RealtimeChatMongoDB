//
//  CaptionLabel.swift
//  RealtimeChatMongoDB
//
//  Created by darktech4 on 31/05/2023.
//

import SwiftUI


struct CaptionLabel: View {
    let title: String
    
    private let lineLimit = 5
    
    var body: some View {
        HStack {
            Text(LocalizedStringKey(title))
                .font(.caption)
                .lineLimit(lineLimit)
                .multilineTextAlignment(.leading)
                .foregroundColor(.text)
            Spacer()
        }
    }
}
