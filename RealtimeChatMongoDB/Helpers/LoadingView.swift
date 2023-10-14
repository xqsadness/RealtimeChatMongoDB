//
//  LoadingView.swift
//  RealtimeChatMongoDB
//
//  Created by darktech4 on 30/05/2023.
//

import SwiftUI

struct LoadingView: View {
    @Binding var show: Bool
    var body: some View {
        ZStack{
            if show{
                Group{
                    Rectangle()
                        .fill(.black.opacity(0.3))
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .padding(15)
                        .background(Color.white)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
        }
        .animation(.easeIn(duration: 0.25), value: show)
    }
}
