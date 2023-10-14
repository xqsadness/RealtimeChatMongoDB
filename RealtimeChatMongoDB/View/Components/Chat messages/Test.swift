//
//  Test.swift
//  RealtimeChatMongoDB
//
//  Created by darktech4 on 09/06/2023.
//

import SwiftUI
import RealmSwift

struct ItemChatDetailView: View {
    @Environment(\.realm) var realm
    var members: [Member]
    var chatMessage: ChatMessage
    var chatster: Chatster
    @ObservedRealmObject var user: User
    
    var body: some View {
        ForEach(members) { member in
            if member.timeJoin < chatMessage.timestamp && member.userName == user.userName{
                if chatMessage.isVisible {
                    ChatRoomBubblesView(chatMessage: chatMessage, chatster: chatster, authorName: chatMessage.author != user.userName ? chatMessage.author : nil)
                        .id(chatMessage._id)
                        .contextMenu {
                            if chatMessage.author == user.userName {
                                Button {
                                    let thaw = chatMessage.thaw()
                                    try? realm.write {
                                        withAnimation {
                                            thaw?.isVisible = false
                                        }
                                    }
                                } label: {
                                    Text("Unsend")
                                }
                            }
                        }
                } else {
                    UnsendView(chatMessage: chatMessage, chatster: chatster, authorName: chatMessage.author != user.userName ? chatMessage.author : nil)
                }
            }
        }
    }
}
