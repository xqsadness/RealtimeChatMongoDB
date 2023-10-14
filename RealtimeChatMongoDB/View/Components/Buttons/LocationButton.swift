//
//  LocationButton.swift
//  RealtimeChatMongoDB
//
//  Created by darktech4 on 05/06/2023.
//

import SwiftUI

struct LocationButton: View {
    let action: () -> Void
    var active = true
    var activeImage = "paperplane.fill"
    var inactiveImage = "paperplane"
    var padding: CGFloat = 4
    
    private enum Dimensions {
        static let buttonSize: CGFloat = 60
        static let activeOpactity = 0.8
        static let disabledOpactity = 0.2
    }
    
    var body: some View {
        Button{
            if active {
                action()
            }
        }label: {
            Image(systemName: active ? activeImage : inactiveImage)
                .imageScale(.large)
                .foregroundStyle(
                    LinearGradient(
                        colors:  [Color(hex: "F90095"), Color(hex: "FF4848")],
                        startPoint: .bottomLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .opacity(active ? Dimensions.activeOpactity : Dimensions.disabledOpactity)
    }
}

