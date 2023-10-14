//
//  ListFriendRequestView.swift
//  RealtimeChatMongoDB
//
//  Created by darktech4 on 06/06/2023.
//

import SwiftUI
import RealmSwift

struct ListFriendRequestView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var realm
    @Environment(\.presentationMode) var presentationMode
    @ObservedRealmObject var user: User
    @ObservedResults(Chatster.self) var chatsters
    @ObservedResults(User.self) var users
    
    @State private var members = [String]()
    
    var body: some View {
        VStack{
            Text("List Request")
                .font(Font.light(size: 18))
                .foregroundColor(.text)
                .frame(maxWidth: .infinity, alignment: .center)
                .overlay(alignment: .leading) {
                    Text("Cancel")
                        .font(Font.light(size: 16))
                        .foregroundColor(Color.blue)
                        .padding(.leading)
                        .onTapGesture {
                            presentationMode.wrappedValue.dismiss()
                        }
                }
                .padding(.vertical)
            
            Divider()
            
            ScrollView {
                ForEach(chatsters, id: \.id){ i in
                    if i.userName == user.userName{
                        let pendingFriends = Array(i.listFriend.filter { $0.status == .pending })
                        
                        if pendingFriends.isEmpty {
                            LottieView(name: "not-found", loopMode: .loop)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 200)
                            
                            Text("You don't have any friend requests.")
                                .font(Font.light(size: 18))
                                .foregroundColor(.gray)
                                .padding(.top,25)
                        } else {
                            ForEach(pendingFriends) { j in
                                HStack{
                                    Text(j.userName)
                                        .foregroundColor(Color.text)
                                        .font(.light(size: 20))
                                    
                                    Spacer()
                                    
                                    HStack {
                                        Button{
                                            do {
                                                try realm.write{
                                                    for n in chatsters {
                                                        if j.userName == n.userName {
                                                            for m in n.listFriend {
                                                                if user.userName == m.userName{
                                                                    let thaw = m.thaw()
                                                                    thaw?.status = .accepted
                                                                }
                                                            }
                                                        }
                                                    }
                                                    let thaw = j.thaw()
                                                    thaw?.status = .accepted
                                                }
                                                LocalNotification.shared.message("Now \(j.userName) and you have become friends ")
                                            } catch {
                                                print(error.localizedDescription)
                                            }
                                        }label: {
                                            Text("Accept")
                                                .foregroundColor(Color.green)
                                                .font(.light(size: 16))
                                                .padding(8)
                                                .background(Color.text2)
                                                .cornerRadius(5)
                                        }
                                        
                                        Button{
                                            do {
                                                try realm.write{
                                                    for n in chatsters {
                                                        if j.userName == n.userName {
                                                            for m in n.listFriend {
                                                                if user.userName == m.userName{
                                                                    let thaw = m.thaw()
                                                                    realm.delete(thaw!)
                                                                }
                                                            }
                                                        }
                                                    }
                                                    let thaw = j.thaw()
                                                    realm.delete(thaw!)
                                                }
                                                
                                                LocalNotification.shared.message("refused")
                                            } catch {
                                                print(error.localizedDescription)
                                            }
                                        }label: {
                                            Text("Refuse")
                                                .foregroundColor(Color.red)
                                                .font(.light(size: 16))
                                                .padding(8)
                                                .background(Color.text2)
                                                .cornerRadius(5)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 5)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal)
                                Divider()
                            }
                        }
                    }
                }
            }
        }
        .onAppear(){
            setSubscription()
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
