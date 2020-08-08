//
//  ChatMessage.swift
//  GuessWho
//
//  Created by Siraj Hamza on 2019-04-04.
//  Copyright © 2019 devHamza. All rights reserved.
//

import Foundation
import MessageKit


enum User: String {
    
    case me = "053493"
    case celebrity = "053496"
    
    static func getName(_ user: User) -> Sender {
        
        switch user {
            
        // Users
        case .me: return Sender(id: me.rawValue, displayName: "User")
        case .celebrity: return Sender(id: celebrity.rawValue, displayName: "Celebrity")
        }
    }
}


class ChatMessage: MessageType {
    
    
    var messageId: String
    var sentDate: Date
    var sender: Sender
    var kind: MessageKind
    
    
    init(kind: MessageKind, sender: Sender) {
        
        self.kind = kind
        self.sender = sender
        self.messageId = UUID().uuidString
        self.sentDate = Date()
    }
    
    
    convenience init(text: String, sender: Sender) {
        
        self.init(kind: .text(text), sender: sender)
    }
}
