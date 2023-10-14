//
//  ContentView.swift
//  RealtimeChatMongoDB
//
//  Created by CycTrung on 29/05/2023.
//

import SwiftUI
import RealmSwift


struct ContentView: View {
    @EnvironmentObject var state: AppState
    @StateObject var showPopup: ShowHideHelper = .init()
    @State var userID: String?
    
    var body: some View {
        NavigationStack {
            if state.loggedIn && userID != nil {
                HomeView(userID: $userID)
                    .environment(\.realmConfiguration,
                                  app.currentUser!.flexibleSyncConfiguration())
                    .environmentObject(showPopup)
            }
            else{
                LoginView(userID: $userID)
            }
        }
        .currentDeviceNavigationViewStyle(alwaysStacked: !state.loggedIn)
        .popup(isPresented: $showPopup.isShow) {
            DetailMemberFromChatView()
                .environmentObject(showPopup)
        }
    }
}

class ShowHideHelper: ObservableObject {
    @Published var isShow = false
    @Published var isFirst = true
    @Published var chatMembers : [Chatster] = []
}
