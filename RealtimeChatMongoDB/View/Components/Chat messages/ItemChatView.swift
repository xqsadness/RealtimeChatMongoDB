//
//  ItemChatView.swift
//  RealtimeChatMongoDB
//
//  Created by darktech4 on 31/05/2023.
//

import SwiftUI
import RealmSwift

struct ItemChatView: View {
    @Environment(\.realm) var realm
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var state: AppState
    @EnvironmentObject var showPopup: ShowHideHelper
    @ObservedResults(Chatster.self) var chatsters
    @ObservedResults(ChatMessage.self, sortDescriptor: SortDescriptor(keyPath: "timestamp", ascending: true)) var chats
    @ObservedRealmObject var user: User
    @Binding var isLogout: Bool
    @State var lastMess = ""
    @State var lastRead: Date? = nil
    @State var now = Date()
    @State var nameChat = ""
    @State var isShow = false
    
    let conversation: Conversation
    var chatMembers: [Chatster] {
        var chatsterList = [Chatster]()
        for member in conversation.members {
            chatsterList.append(contentsOf: chatsters.filter("userName = %@", member.userName))
        }
        return chatsterList
    }
    
    var body: some View {
        NavigationLink {
            if isLogout {
                ChatRoomView(user: user, nameChat: $nameChat, conversation: conversation)
                    .navigationBarBackButtonHidden(true)
            }
            else {
                ChatRoomView(user: user, nameChat: $nameChat, conversation: conversation)
                    .environment(\.realmConfiguration, app.currentUser!.flexibleSyncConfiguration())
                    .navigationBarBackButtonHidden(true)
            }
        } label: {
            HStack{
                ScrollView(.horizontal, showsIndicators: true) {
                    LazyHGrid(rows: [  GridItem(.flexible())], alignment: .center, spacing: 0) {
                        ForEach(chatMembers) { member in
                            if member.userName != user.userName{
                                ZStack {
                                    if let photo = member.avatarImage?.thumbNail {
                                        let mugShot = UIImage(data: photo)
                                        Image(uiImage: mugShot ?? UIImage())
                                            .renderingMode(.original)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .clipShape(Circle())
                                            .frame(width: 46,height: 46)
                                    }else{
                                        Image("default")
                                            .renderingMode(.original)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .clipShape(Circle())
                                            .frame(width: 46,height: 46)
                                    }
                                    HStack {
                                        Spacer()
                                        VStack {
                                            Spacer()
                                            OnOffCircleView(online: member.presenceState == .onLine ? true : false)
                                        }
                                    }
                                }
                                //                                .onTapGesture {
                                //                                    showPopup.chatMembers = chatMembers
                                //                                    withAnimation {
                                //                                        showPopup.isShow.toggle()
                                //                                    }
                                //                                }
                            }
                        }
                    }
                    .frame(height: 46)
                }
                .frame(width: 46)
                
                LazyVStack(spacing: 10){
                    ForEach(chatMembers){ member in
                        if member.userName != user.userName{
                            HStack{
                                if let name = member.displayName{
                                    if !name.isEmpty{
                                        Text("\(name)")
                                            .font(.light(size: 16))
                                            .foregroundColor(Color.text)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .onAppear{
                                                nameChat = name
                                            }
                                        //                                            .onChange(of: name) { name in
                                        //                                                nameChat = name
                                        //                                            }
                                    }else{
                                        Text(member.userName)
                                            .font(.light(size: 16))
                                            .foregroundColor(Color.text)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .onAppear{
                                                nameChat = member.userName
                                            }
                                    }
                                }
                                
                                Spacer()
                                
                                if let time = lastRead{
                                    if !conversation.isDelete{
                                        TextDate(date: time)
                                            .font(.light(size: 12))
                                            .foregroundColor(Color.background2)
                                    }
                                }
                            }
                            
                            if !conversation.isDelete{
                                Text(lastMess)
                                    .font(.light(size: 14))
                                    .foregroundColor(Color.background2)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                            }
                            else{
                                Text("")
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 10)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 90)
        }
        .onAppear{
            setSubscription()
            for i in chats{
                if i.conversationID == conversation.id{
                    if i.image != nil{
                        lastMess = "Photo"
                    }else if !i.location.isEmpty{
                        lastMess = "Location"
                    }else if !i.text.isEmpty{
                        lastMess = i.text
                    }
                    lastRead = i.timestamp
                }
            }
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

struct OnOffCircleView: View {
    let online: Bool
    
    private enum Dimensions {
        static let frameSize: CGFloat = 14.0
        static let innerCircleSize: CGFloat = 10
    }
    
    var body: some View {
        ZStack() {
            Circle()
                .fill(Color.gray)
                .frame(width: Dimensions.frameSize, height: Dimensions.frameSize)
            Circle()
                .fill(online ? Color.green : Color.red)
                .frame(width: Dimensions.innerCircleSize, height: Dimensions.innerCircleSize)
        }
    }
}
