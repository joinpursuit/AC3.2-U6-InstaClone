//
//  Vote.swift
//  InstaClone
//
//  Created by Tong Lin on 2/8/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import Foundation

class Vote{
    let voteID: String
    let activities: [String: Bool]
    
    init(voteID: String, activities: [String: Bool]) {
        self.voteID = voteID
        self.activities = activities
    }
}
