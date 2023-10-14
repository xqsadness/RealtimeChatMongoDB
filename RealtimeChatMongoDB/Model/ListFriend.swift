//
//  FriendList.swift
//  RealtimeChatMongoDB
//
//  Created by darktech4 on 06/06/2023.
//

import Foundation
import RealmSwift

class ListFriend: EmbeddedObject, ObjectKeyIdentifiable {
    convenience init(id: String = UUID().uuidString, userName: String = "", status: FriendStatus) {
        self.init()
        self.id = id
        self.userName = userName
        self.status = status
    }
    
    @Persisted var id = UUID().uuidString
    @Persisted var userName = ""
    @Persisted var status: FriendStatus = .defaults
    
    enum FriendStatus: String, PersistableEnum {
        case pending
        case wait
        case accepted
        case defaults
    }
}
