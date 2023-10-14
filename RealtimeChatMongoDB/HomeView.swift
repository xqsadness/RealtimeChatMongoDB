//
//  HomeView.swift
//  RealtimeChatMongoDB
//
//  Created by darktech4 on 29/05/2023.
//

import SwiftUI
import RealmSwift
import CoreLocation

struct HomeView: View {
    @EnvironmentObject var state: AppState
    @EnvironmentObject var showPopup: ShowHideHelper
    @Environment(\.realm) var realm
    @ObservedResults(User.self) var users
    @ObservedResults(Chatster.self) var chatster
    @ObservedResults(ChatMessage.self, sortDescriptor: SortDescriptor(keyPath: "timestamp", ascending: true)) var chatMessage

    @State var isFullscreen = true
    @State private var showingAddFriend = false
    @State private var showinglistFriendRequest = false
    @State private var showingAddChat = false
    @State var isLogout = false
    @State var ip = ""
    @State var pendingFriendCount = 0
    @Binding var userID: String?
    
    @ObservedObject var locationManager = LocationHelper.shared
    
    private let sortDescriptors = [
        SortDescriptor(keyPath: "unreadCount", ascending: false),
        SortDescriptor(keyPath: "displayName", ascending: true)
    ]
    
    var body: some View {
        VStack{
            HStack{
                NavigationLink{
                    if let user = users.first{
                        ProfileView(user: user, userID: $userID, isLogout: $isLogout)
                            .navigationBarBackButtonHidden(true)
                            .environmentObject(showPopup)
                    }
                }label: {
                    ZStack(alignment: .bottomTrailing){
                        if let avatarImageData = users.first?.userPreferences?.avatarImage?.thumbNail,
                           let avatarImage = UIImage(data: avatarImageData) {
                            Image(uiImage: avatarImage)
                                .resizable()
                                .clipShape(Circle())
                                .frame(width: 46, height: 46)
                                .padding(.trailing, 10)
                        } else {
                            Image("default")
                                .resizable()
                                .clipShape(Circle())
                                .frame(width: 46, height: 46)
                                .padding(.trailing, 10)
                        }
                        
                        if let firstUser = users.first {
                            OnOffCircleView(online: firstUser.presenceState == .onLine ? true : false)
                                .padding(.trailing, 10)
                        }
                    }
                }
                
                VStack(spacing: 4){
                    let displayName = users.first?.userPreferences?.displayName ?? ""
                    let extractedName = extractNameFromEmail(email: users.first?.userName ?? "nil") ?? "nil"
                    
                    Text("Hi, \(displayName.isEmpty ? extractedName : displayName)!")
                        .font(.regularTitle(size: 36))
                        .foregroundColor(Color.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    
                    Text(ip)
                        .font(.light(size: 12))
                        .foregroundColor(Color.background2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()

            }
            .padding(.horizontal,25)
            
            HStack{
                Button{
                    showingAddFriend.toggle()
                }label: {
                    Text("Add friends")
                        .font(.regularTitle(size: 18))
                        .foregroundColor(Color.blue)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Button{
                    showinglistFriendRequest.toggle()
                }label: {
                    HStack{
                        Text("List Friend Request")
                            .font(.regularTitle(size: 18))
                            .foregroundColor(Color.blue)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        
                        Text("\(pendingFriendCount)")
                            .font(.regularTitle(size: 14))
                            .foregroundColor(Color.text2)
                            .frame(width: 20,height: 20)
                            .background(Color.red)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal,25)
            .padding(.top)
            
            if let user = users.first{
                let conversations = user.conversations.sorted(by: sortDescriptors)
                
                let conversationsFilter = Array(conversations)
                
                if conversationsFilter.isEmpty{
                    LottieView(name: "not-found", loopMode: .loop)
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                    
                    Text("You don't have any chat !")
                        .font(.light(size: 17))
                        .foregroundColor(Color.text)
                        .frame(maxWidth: .infinity, alignment: .center)
                }else{
                    List{
                        
                        ForEach(conversationsFilter){ item in
                            ItemChatView(user: user, isLogout: $isLogout, conversation: item)
                                .listRowSeparator(.hidden)
                                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                                .overlay(alignment : .top){
                                    Divider()
                                }
                                .contextMenu {
                                    Button {
                                        try! realm.write {
                                            for i in item.members{
                                                if i.userName == user.userName{
                                                    let time = Date()
                                                    i.thaw()?.timeJoin = time
                                                    item.thaw()?.isDelete = true
                                                }
                                            }
                                        }
                                        
                                        LocalNotification.shared.message("You have deleted all chats")
                                    } label: {
                                        Label("Delete this chat", systemImage: "globe")
                                    }
                                }
                            
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listStyle(PlainListStyle())
                    .padding(.horizontal)
                    .scrollIndicators(ScrollIndicatorVisibility.hidden)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity,maxHeight: .infinity)
        .sheet(isPresented: $showingAddFriend) {
            if let user = users.first{
                AddFriendView(user: user,showingAddFriend: $showingAddFriend)
                    .environmentObject(state)
                    .environment(\.realmConfiguration, app.currentUser!.flexibleSyncConfiguration())
            }
        }
        .sheet(isPresented: $showinglistFriendRequest) {
            if let user = users.first{
                ListFriendRequestView(user: user)
                    .environmentObject(state)
                    .environment(\.realmConfiguration, app.currentUser!.flexibleSyncConfiguration())
            }
        }
        .sheet(isPresented: $showingAddChat) {
            if let user = users.first{
                AddChatView(user: user)
                    .environmentObject(state)
                    .environment(\.realmConfiguration, app.currentUser!.flexibleSyncConfiguration())
            }
        }
        .overlay(alignment: .bottomTrailing){
            Button{
                showingAddChat.toggle()
            }label: {
                HStack {
                    Text("New Chat")
                        .font(Font.light(size: 14))
                        .foregroundColor(.text)
                    
                    Image(systemName: "plus")
                        .imageScale(.large)
                        .foregroundColor(Color.blue)
                        .padding(8)
                        .background(Color.text2)
                        .clipShape(Circle())
                }
            }
            .padding(.trailing,25)
        }
        .onAppear{
            setSubscription()
            getCityNameFromCoordinate(latitude: locationManager.currentLocation.latitude, longitude: locationManager.currentLocation.longitude) { loca in
                self.ip = loca!
            }
        }
        .onChange(of: chatster) { newValue in
            for i in chatster{
                if let user = users.first{
                    if i.userName == user.userName{
                        pendingFriendCount = i.listFriend.filter { $0.status == .pending }.count
                    }
                }
            }
        }
        .onChange(of: locationManager.currentLocation.latitude, perform: { newValue in
            getCityNameFromCoordinate(latitude: locationManager.currentLocation.latitude, longitude: locationManager.currentLocation.longitude) { loca in
                self.ip = loca!
            }
        })
    }

    private func setSubscription() {
        let subscriptions = realm.subscriptions
        subscriptions.update {
            if let currentSubscription = subscriptions.first(named: "user_id") {
                print("Replacing subscription for user_id")
                currentSubscription.updateQuery(toType: User.self) { user in
                    user._id == userID!
                }
                
            } else {
                print("Appending subscription for user_id")
                subscriptions.append(QuerySubscription<User>(name: "user_id") { user in
                    user._id == userID!
                })
            }
        }
    }
    
    func logout(){
        DispatchQueue.main.async {
            state.shouldIndicateActivity = true
            app.currentUser?.logOut { error in
                if let error = error {
                    print("\(error.localizedDescription)")
                } else {
                    state.shouldIndicateActivity = false
                    withAnimation {
                        userID = nil
                    }
                    LocalNotification.message("Logout success!")
                }
            }
        }
    }
    
    func extractNameFromEmail(email: String) -> String? {
        let components = email.components(separatedBy: "@")
        guard let name = components.first else {
            return nil
        }
        return name
    }
    
    func getCityNameFromCoordinate(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: @escaping (String?) -> Void) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Error: \(error)")
                completion(nil)
                return
            }
            
            if let placemark = placemarks?.first {
                if let city = placemark.locality {
                    completion(city)
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }
    
}
