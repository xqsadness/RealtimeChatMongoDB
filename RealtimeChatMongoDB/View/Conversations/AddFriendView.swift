//
//  NewConversationView.swift
//  RealtimeChatMongoDB
//
//  Created by darktech4 on 31/05/2023.
//

import SwiftUI
import RealmSwift

struct AddFriendView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var realm
    @Environment(\.presentationMode) var presentationMode
    @ObservedRealmObject var user: User
    @ObservedResults(Chatster.self) var chatsters
    @ObservedResults(User.self) var users
    
    @State private var name = "none"
    @State private var members = [String]()
    @State private var candidateMember = ""
    @State private var candidateMembers = [String]()
    @Binding var showingAddFriend: Bool
    
    var isPreview = false
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
        let searchBinding = Binding<String>(
            get: { candidateMember },
            set: {
                candidateMember = $0
                searchUsers()
            }
        )
        NavigationView {
            ZStack {
                VStack {
                    CaptionLabel(title: "List User")
                    SearchBox(searchText: searchBinding)
                    if memberList.isEmpty{
                        Text("There are no friend yet ! ")
                            .font(.light(size: 16))
                            .foregroundColor(Color.text)
                            .padding()
                    }else{
                        List {
                            ForEach(memberList, id: \.self) { candidateMember in
                                Button(action: { addMember(candidateMember) }) {
                                    HStack {
                                        Text(candidateMember)
                                        Spacer()
                                        Image(systemName: "plus.circle.fill")
                                            .renderingMode(.original)
                                    }
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    CaptionLabel(title: "Friends")
                    ForEach(chatsters, id: \.id){ i in
                        if i.userName == user.userName{
                            let listSendFriends = Array(i.listFriend)
                            
                            if listSendFriends.isEmpty{
                                LottieView(name: "not-found", loopMode: .loop)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 200)
                                
                                Text("No friends ! .")
                                    .foregroundColor(.gray)
                            }else{
                                ScrollView{
                                    ForEach(listSendFriends) { friend in
                                        HStack{
                                            Text(friend.userName)
                                                .font(.light(size: 16))
                                                .foregroundColor(Color.text)
                                            
                                            Spacer()
                                            
                                            switch friend.status {
                                            case .accepted:
                                                HStack{
                                                    Text("Friend")
                                                        .font(.light(size: 15))
                                                        .foregroundColor(Color.green)
                                                    Image(systemName: "checkmark")
                                                        .imageScale(.small)
                                                        .foregroundColor(Color.green)
                                                }
                                            case .pending:
                                                Text("Pending")
                                                    .font(.light(size: 15))
                                                    .foregroundColor(Color.blue)
                                            case .wait:
                                                Text("Wait")
                                                    .font(.light(size: 15))
                                                    .foregroundColor(Color.yellow)
                                            case .defaults:
                                                EmptyView()
                                            }
                                        }
                                        .padding(12)
                                        .background(Color.white)
                                        .cornerRadius(10)
                                    }
                                }
                                .padding()
                                .background(Color(.secondarySystemBackground))
                            }
                        }
                    }
                    Spacer()
                }
                Spacer()
                if let error = state.error {
                    Text("Error: \(error)")
                        .foregroundColor(Color.red)
                }
            }
            .padding()
            .navigationBarTitle("Add friends", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Dismiss") { presentationMode.wrappedValue.dismiss() }
                //                trailing: VStack {
                //                    Button(action: sendAddFriends) {
                //                        Text("Add")
                //                    }
                //                }
                //                    .disabled(isEmpty)
                //                    .padding()
            )
        }
        .onAppear(){
            setSubscription()
            searchUsers()
        }
    }
    
    func sendAddFriends() {
        state.error = nil
        let thawedChatsters = chatsters.thaw()!
        
        for chaster in thawedChatsters {
            for i in members {
                if user.userName == chaster.userName {
                    let existingList = chaster.listFriend.filter { $0.userName == i }
                    if existingList.isEmpty {
                        try! thawedChatsters.realm?.write {
                            chaster.listFriend.append(ListFriend(userName: i, status: .wait))
                        }
                    }
                }
                else if chaster.userName == i{
                    let existingList = chaster.listFriend.filter { $0.userName == user.userName }
                    if existingList.isEmpty {
                        try! thawedChatsters.realm?.write {
                            chaster.listFriend.append(ListFriend(userName: user.userName, status: .pending))
                        }
                    }
                }
            }
        }
        LocalNotification.shared.message("Send request success")
        showingAddFriend = false
    }
    
    private func searchUsers() {
        var candidateChatsters: Results<Chatster>
        if candidateMember == "" {
            candidateChatsters = chatsters
        } else {
            let predicate = NSPredicate(format: "userName CONTAINS[cd] %@", candidateMember)
            candidateChatsters = chatsters.filter(predicate)
        }
        candidateMembers = []
        candidateChatsters.forEach { chatster in
            if !members.contains(chatster.userName) && chatster.userName != user.userName {
                candidateMembers.append(chatster.userName)
            }
        }
    }
    
    private func addMember(_ newMember: String) {
        state.error = nil
        if members.contains(newMember) {
            state.error = "\(newMember) is already part of this chat"
        } else {
            members.append(newMember)
            candidateMember = ""
            searchUsers()
        }
        
        sendAddFriends()
    }
    
    private func deleteMember(at offsets: IndexSet) {
        members.remove(atOffsets: offsets)
    }
    
    //giúp đồng bộ dữ liệu chatster giữa client và server thông qua realtime sync.
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
