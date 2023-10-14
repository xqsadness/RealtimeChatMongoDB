//
//  SaveConversationButton.swift
//  RealtimeChatMongoDB
//
//  Created by darktech4 on 31/05/2023.
//

import SwiftUI
import RealmSwift

struct SaveConversationButton: View {
    @EnvironmentObject var state: AppState
    
    @ObservedRealmObject var user: User
    
    let name: String
    let members: [String]
    var done: () -> Void = { }
    
    var body: some View {
        Button(action: saveConversation) {
            Text("Create")
        }
    }
    
    private func saveConversation() {
        state.error = nil
        let conversation = Conversation()
        conversation.displayName = name
        conversation.members.append(Member(userName: user.userName, state: .active, time: Date()))
        conversation.members.append(objectsIn: members.map { Member($0) })
        $user.conversations.append(conversation)
        done()
    }
}
