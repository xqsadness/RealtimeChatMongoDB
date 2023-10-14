//
//  HelperFile.swift
//  RealtimeChatMongoDB
//
//  Created by darktech4 on 02/06/2023.
//

import Foundation
import SwiftUI

extension View {
    func popup<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        return ZStack {
            self
            
            if isPresented.wrappedValue {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                    .onTapGesture {
                        isPresented.wrappedValue = false
                    }
                
                content()
                    .transition(.scale)
            }
        }
    }
}

extension View {
    public func currentDeviceNavigationViewStyle(alwaysStacked: Bool) -> AnyView {
        if UIDevice.current.userInterfaceIdiom == .pad && !alwaysStacked {
            return AnyView(self.navigationViewStyle(DefaultNavigationViewStyle()))
        } else {
            return AnyView(self.navigationViewStyle(StackNavigationViewStyle()))
        }
    }
}
