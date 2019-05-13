//
//  DateHelpers.swift
//  Post
//
//  Created by Will morris on 5/13/19.
//  Copyright © 2019 devmtn. All rights reserved.
//

import Foundation

extension Date {
    
    func stringValue(timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeZone = .autoupdatingCurrent

        return formatter.string(from: date)
    }
    
}
