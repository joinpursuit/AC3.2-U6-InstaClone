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
    let title: String
    let category: String
    let time: String
    let votes: [String: String]
    
    init(photoID: String, title: String, category: String, time: String, votes: [String: String]) {
        self.photoID = photoID
        self.title = title
        self.category = category
        self.time = time
        self.votes = votes
    }
}
