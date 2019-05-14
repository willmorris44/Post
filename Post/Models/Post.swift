//
//  Post.swift
//  Post
//
//  Created by Will morris on 5/13/19.
//  Copyright © 2019 devmtn. All rights reserved.
//

import Foundation

struct Post: Codable {
    
    let text: String
    let timestamp: TimeInterval
    let username: String
    var queryTimestamp: TimeInterval {
        return (self.timestamp - 0.00000001)
    }
    
    init(text: String, username: String, timestamp: TimeInterval = Date().timeIntervalSince1970) {
        self.text = text
        self.username = username
        self.timestamp = timestamp
    }
    
}
