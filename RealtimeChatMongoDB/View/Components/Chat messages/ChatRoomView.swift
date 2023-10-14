//
//  ChatRoomView.swift
//  RealtimeChatMongoDB
//
//  Created by darktech4 on 01/06/2023.
//

import SwiftUI
import RealmSwift
import Lottie

let userTest = app.currentUser!

struct ChatRoomView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) var dismiss
    @Environment(\.realm) var realm
    @ObservedRealmObject var user: User
    @ObservedResults(Chatster.self) var chatsters
    @ObservedResults(ChatMessage.self, sortDescriptor: SortDescriptor(keyPath: "timestamp", ascending: true)) var chats
    @Binding var nameChat: String
    @State private var realmChatsNotificationToken: NotificationToken?
    @State private var latestChatId = ""
    
    var conversation: Conversation?
    var chatster: Chatster? {
        chatsters.filter("userName = %@", chats.first?.author ?? "nil").first
    }
    //
  @State var paging = 20
    var body: some View {
        VStack{
            HStack{
                Image("back")
                    .resizable()
                    .frame(width: 34,height: 34)
                    .onTapGesture {
                        dismiss()
                    }
                
                Spacer()
                
                Text(nameChat)
                    .foregroundColor(Color.text)
                    .font(.regularTitle(size: 32))
                
                Spacer()
            }
            .padding(.bottom,40)
            .padding(.horizontal)
            
            HStack(spacing: 13) {
                Divider()
                    .rotationEffect(.degrees(-90))
                    .frame(height: 200)
                
                Text("INTRODUCE YOURSELF")
                    .foregroundColor(Color.gray.opacity(0.3))
                    .font(.light(size: 12))
                    .frame(maxWidth: .infinity)
                
                Divider()
                    .rotationEffect(.degrees(-90))
                    .frame(height: 200)
            }
            .frame(height: 30)
            .padding(.horizontal)
            
            Spacer()
            
            VStack{
                ScrollView(.vertical, showsIndicators: false) {
                    ScrollViewReader { proxy in
                        VStack {
                            ForEach(chats.suffix(paging)) { chatMessage in
                                if let chatster = chatster {
                                    if let members = conversation?.members {
                                        ItemChatDetailView(members: Array(members), chatMessage: chatMessage, chatster: chatster, user: user)
                                    }
                                }
                            }
                        }
                        .onChange(of: latestChatId) { target in
                            withAnimation {
                                proxy.scrollTo(target, anchor: .bottom)
                            }
                        }
                        .onAppear {
                            scrollToBottom()
                        }
                    }
                }
                .refreshable {
                    paging += 10
                }
            }
            .frame(maxWidth: .infinity,maxHeight: .infinity)
            
            Spacer()
            
            ChatInputBox(user: user, send: sendMessage, focusAction: scrollToBottom)
                .padding(.horizontal,5)
        }
        .environment(\.realmConfiguration,
                      app.currentUser!.flexibleSyncConfiguration())
        .onAppear {
            loadChatRoom()
        }
        .onDisappear {
            closeChatRoom()
        }
    }
    
    private func loadChatRoom() {
        scrollToBottom()
        setSubscription()
        realmChatsNotificationToken = chats.thaw()?.observe { _ in
            scrollToBottom()
        }
    }
    
    private func closeChatRoom() {
        clearSunscription()
        if let token = realmChatsNotificationToken {
            token.invalidate()
        }
    }
    
    private func sendMessage(chatMessage: ChatMessage) {
        
        guard let conversation = conversation else {
            print("comversation not set")
            return
        }
        chatMessage.conversationID = conversation.id
      
        try? realm.write{
            conversation.thaw()?.isDelete = false
//            conversation.thaw()?.lastTime = chatMessage.timestamp
//            conversation.thaw()?.lastPhoto = chatMessage.image
//            conversation.thaw()?.lastLocation = chatMessage.location
        }
        
        $chats.append(chatMessage)
        print("comversation not set")
    }
    
    private func scrollToBottom() {
        var latestVisibleChatId: String?
        
        for chat in chats.reversed() {
            if chat.isVisible {
                latestVisibleChatId = chat._id
                break
            }
        }
        latestChatId = latestVisibleChatId ?? chats.last?._id ?? ""
    }
    
    private func setSubscription() {
        let subscriptions = realm.subscriptions
        subscriptions.update {
            if let conversation = conversation {
                if let currentSubscription = subscriptions.first(named: "conversation") {
                    currentSubscription.updateQuery(toType: ChatMessage.self) { chatMessage in
                        chatMessage.conversationID == conversation.id
                    }
                } else {
                    subscriptions.append(QuerySubscription<ChatMessage>(name: "conversation") { chatMessage in
                        chatMessage.conversationID == conversation.id
                    })
                }
            }
        }
    }

    private func clearSunscription() {
        print("Leaving room, clearing subscription")
        let subscriptions = realm.subscriptions
        subscriptions.update {
            subscriptions.remove(named: "conversation")
        }
    }
}


