//
//  PhotoActivity.swift
//  InstaClone
//
//  Created by C4Q on 2/10/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import Foundation


class PhotoActivity {
    var date: String
    var value: Bool
    var time: String
    var username: String
    var userID: String
    
    init(date: String, value: Bool, time: String, username: String, userID: String) {
        self.date = date
        self.time = time
        self.value = value
        self.username = username
        self.userID = userID
    }
    
    convenience init? (_ dict: [String: AnyObject]) {
        print(dict["value"] as! Bool)
        guard let value = dict["value"] as? Bool,
            let date = dict["date"] as? String,
            let time = dict["time"] as? String,
            let username = dict["username"] as? String,
            let userID = dict["userID"] as? String else {
                print("not working")
                return nil }
        self.init(date: date, value: value, time: time, username: username, userID: userID)
    }
}
