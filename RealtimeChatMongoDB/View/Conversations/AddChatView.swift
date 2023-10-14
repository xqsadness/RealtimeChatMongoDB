//
//  AddChatView.swift
//  RealtimeChatMongoDB
//
//  Created by darktech4 on 07/06/2023.
//

import SwiftUI
import RealmSwift

struct AddChatView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var realm
    @Environment(\.presentationMode) var presentationMode
    @ObservedRealmObject var user: User
    @ObservedResults(Chatster.self) var chatsters
    @State private var name = "none"
    @State private var searchBinding = ""
    @State private var members = [String]()
    @State private var candidateMember = ""
    @State private var candidateMembers = [String]()
    
    private var isEmpty: Bool {
        !( name != "" && members.count > 0)
    }
    
    private var memberList: [String] {
        candidateMember == ""
        ? chatsters.compactMap {
            user.userName != $0.userName && !members.contains($0.userName)
            ? $0.userName
            : nil }
        : candidateMembers
    }
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
//                    SearchBox(searchText: $searchBinding)
                    
                    CaptionLabel(title: "List Friend")
                    if memberList.isEmpty{
                        LottieView(name: "not-found", loopMode: .loop)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 200)
                        
                        Text("There are no members yet ! ")
                            .font(.light(size: 16))
                            .foregroundColor(Color.text)
                            .padding()
                    }else{
                        List {
                            ForEach(chatsters, id: \.id){ i in
                                if i.userName == user.userName{
                                    let acceptedFriends = Array(i.listFriend.filter { $0.status == .accepted })
                                    
                                    if acceptedFriends.isEmpty {
                                        LottieView(name: "not-found", loopMode: .loop)
                                                    .frame(maxWidth: .infinity)
                                                    .frame(height: 200)
                                        
                                        Text("No friends are accepted.")
                                            .foregroundColor(.gray)
                                    } else {
                                        ForEach(acceptedFriends) { friend in
                                            Button(action: {
                                                addMember(friend.userName)
                                            }) {
                                                HStack {
                                                    Text(friend.userName)
                                                    Spacer()
                                                    Image(systemName: "plus.circle.fill")
                                                        .renderingMode(.original)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Divider()
                    
                    Spacer()
                }
                Spacer()
                if let error = state.error {
                    Text("Error: \(error)")
                        .foregroundColor(Color.red)
                }
            }
            .padding()
            .navigationBarTitle("Add chats", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Dismiss") { presentationMode.wrappedValue.dismiss() }
            )
        }
        .onAppear(){
            setSubscription()
        }
    }
    
    private func addMember(_ newMember: String) {
        state.error = nil
        if members.contains(newMember) {
            //            state.error = "\(newMember) is already part of this chat"
            presentationMode.wrappedValue.dismiss()
        } else if !user.conversations.contains(where: { $0.members.contains(where: { $0.userName == newMember }) }) {
            members.append(newMember)
            candidateMember = ""
            saveConversation()
        } else {
            presentationMode.wrappedValue.dismiss()
            LocalNotification.shared.message("The conversation already exists")
        }
    }
    
    private func saveConversation() {
        state.error = nil
        let conversation = Conversation()
        conversation.displayName = name
        conversation.members.append(Member(userName: user.userName, state: .active, time: Date()))
        conversation.members.append(objectsIn: members.map { Member($0) })
        $user.conversations.append(conversation)
        presentationMode.wrappedValue.dismiss()
        LocalNotification.shared.message("Create successful conversation!")
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
