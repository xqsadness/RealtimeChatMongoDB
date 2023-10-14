//
//  AuthorView.swift
//  RealtimeChatMongoDB
//
//  Created by darktech4 on 02/06/2023.
//

import SwiftUI
import RealmSwift

struct AuthorView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var realm
    @ObservedResults(Chatster.self) var chatsters
    @StateRealmObject var author :Chatster
    
    var isMyMessage: Bool
    private enum Dimensions {
        static let authorHeight: CGFloat = 25
        static let padding: CGFloat = 4
    }
    
    var body: some View {
        if !isMyMessage{
            HStack {
                if author.avatarImage?.thumbNail != nil{
                    if let photo = author.avatarImage {
                        VStack {
                            ThumbNailView(photo: photo)
                        }
                        .frame(width: 40, height: 40)
                        .background(Color.gray)
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                        .cornerRadius(4)
                    }
                }else{
                    Image("default")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                        .cornerRadius(4)
                }
                Spacer()
            }
            .onAppear(perform: setSubscription)
            .frame(maxHeight: Dimensions.authorHeight)
            .padding(Dimensions.padding)
        }
    }
    
    private func setSubscription() {
        let subscriptions = realm.subscriptions
        subscriptions.update {
            if let currentSubscription = subscriptions.first(named: "all_chatsters") {
                currentSubscription.updateQuery(toType: Chatster.self) { chatster in
                    chatster.userName != ""
                }
                
            } else {
                subscriptions.append(QuerySubscription<Chatster>(name: "all_chatsters") { chatster in
                    chatster.userName != ""
                })
            }
        }
    }
}

