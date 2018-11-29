//
//  Message.swift
//  testChat
//
//  Created by Min Duan on 11/23/18.
//

import Foundation
import UIKit
import MessageKit


struct Member {
    let name: String
    let color: UIColor
}

struct Message {
    let member: Member
    let text: String
    let messageId: String
    let date: Date?
}

extension Message: MessageType {
    var sender: Sender {
        return Sender(id: member.name, displayName: member.name)
    }
    
    var sentDate: Date {
        return date ?? Date()
    }
    
    var kind: MessageKind {
        return .text(text)
    }
}

