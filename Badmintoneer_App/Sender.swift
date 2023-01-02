//
//  Sender.swift
//  Badmintoneer_App
//
//  Created by Shawn Tham on 27/5/21.
//

import UIKit
import MessageKit

class Sender: SenderType {
    var senderId: String
    var displayName: String
    
    init(id: String, name: String) {
        self.senderId = id
        self.displayName = name
    }
}
