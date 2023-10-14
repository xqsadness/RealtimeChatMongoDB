//
//  DetailMemberFromChatView.swift
//  RealtimeChatMongoDB
//
//  Created by darktech4 on 02/06/2023.
//

import SwiftUI

struct DetailMemberFromChatView: View {
    @EnvironmentObject var showPopup: ShowHideHelper
    
    var body: some View {
        VStack{
            Text("Detail member")
                .font(.regularTitle(size: 25))
                .foregroundColor(Color.text)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("\(showPopup.chatMembers.count) members")
                .font(.light(size: 14))
                .foregroundColor(Color.text)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(alignment: .center) {
                    ForEach(showPopup.chatMembers.reversed()) { member in
                        HStack{
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
                            }
                            .frame(width: 48)
                            .padding(.top)
                            
                            VStack{
                                if !member.displayName!.isEmpty{
                                    Text(member.displayName ?? "null")
                                        .font(.regularTitle(size: 19))
                                        .foregroundColor(Color.text)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }else{
                                    Text(extractNameFromEmail(email: member.userName) ?? "null")
                                        .font(.regularTitle(size: 19))
                                        .foregroundColor(Color.text)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                
                                Text(member.presenceState == .onLine ? "Online" : "Offline")
                                    .font(.regularTitle(size: 17))
                                    .foregroundColor(member.presenceState == .onLine ? Color.green : Color.gray)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .onAppear{
            print(showPopup.chatMembers)
        }
        .padding()
        .frame(height: 250)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .padding(.horizontal,25)
    }
    
    func extractNameFromEmail(email: String) -> String? {
        let components = email.components(separatedBy: "@")
        guard let name = components.first else {
            return nil
        }
        return name
    }
}
