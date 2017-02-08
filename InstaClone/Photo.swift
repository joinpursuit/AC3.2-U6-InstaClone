//
//  Photo.swift
//  InstaClone
//
//  Created by Tong Lin on 2/8/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import Foundation

class Photo{
    let photoID: String
    let uploadedBy: String
    let title: String
    let category: String
    let filePath: String
    let date: String
    let time: String
    var upCount: Int
    var downCount: Int
    
    init(photoID: String, uploadedBy: String, title: String, category: String, filePath: String, date: String, time: String, upCount: Int, downCount: Int) {
        self.photoID = photoID
        self.uploadedBy = uploadedBy
        self.title = title
        self.category = category
        self.filePath = filePath
        self.date = date
        self.time = time
        self.upCount = upCount
        self.downCount = downCount
    }
}
