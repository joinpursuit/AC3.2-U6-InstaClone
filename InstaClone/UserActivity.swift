//
//  UserActivity.swift
//  InstaClone
//
//  Created by C4Q on 2/10/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import Foundation

enum TypeOfActivity {
    case photo, vote
}

class UserActivity {
    var imageName: String
    var date: String
    var time: String
    var photoID: String
    var value: Bool?
    var filePath: String
    
    init(imageName: String, date: String, time: String, photoID: String, value: Bool?, filePath: String) {
        self.imageName = imageName
        self.date = date
        self.time = time
        self.photoID = photoID
        self.value = value
        self.filePath = filePath
    }
    
    convenience init?(dict: [String : AnyObject], value: Bool?) {
        guard let imageName = dict["imageName"] as? String,
        let date = dict["date"] as? String,
        let time = dict["time"] as? String,
        let photoID = dict["photoID"] as? String,
            let filePath = dict["filePath"] as? String  else { return nil }
                
        self.init(imageName: imageName, date: date, time: time, photoID: photoID, value: value, filePath: filePath)
    }
    
}
