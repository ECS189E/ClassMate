//
//  Channel.swift
//  testChat
//
//  Created by Min Duan on 11/23/18.
//

import Foundation
import Firebase

struct ChatRoom
{
    let roomID : String?
    let name : String
    let type : Int
    let messages : [Message]
    
    init(name: String) {
        roomID = nil
        self.name = name
        self.type = 0 // 0 for private chat, 1 for public class chat
        self.messages = []
    }
}
