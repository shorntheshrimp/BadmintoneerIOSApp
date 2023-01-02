//
//  Channel.swift
//  Badmintoneer_App
//
//  Created by Shawn Tham on 27/5/21.
//

import UIKit

class Channel: NSObject {
    let id: String
    let name: String
    let category: String
    let authorname: String
    let authorid: String
    
    init(id: String, name: String, category: String, authorname: String, authorid: String){
        self.id = id
        self.name = name
        self.category = category
        self.authorname = authorname
        self.authorid = authorid
    }

}
