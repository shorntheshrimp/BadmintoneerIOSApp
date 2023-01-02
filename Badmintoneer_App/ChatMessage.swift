//
//  ChatMessage.swift
//  Badmintoneer_App
//
//  Created by Shawn Tham on 27/5/21.
//

import UIKit
import MessageKit

class ChatMessage: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
    init(sender: Sender, messageId: String, sentDate: Date, message: String) {
        self.sender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.kind = .text(message)
    }
}
