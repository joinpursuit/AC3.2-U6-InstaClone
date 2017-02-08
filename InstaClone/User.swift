//
//  User.swift
//  InstaClone
//
//  Created by Tong Lin on 2/8/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import Foundation

class User{
    let email: String
    var profileImage: Photo?
    var votes: [String: Bool]
    var uploaded: [String]
    
    init(email: String, profileImage: Photo?, votes: [String: Bool], uploaded: [String]) {
        self.email = email
        self.profileImage = profileImage
        self.votes = votes
        self.uploaded = uploaded
    }
    
    convenience init(data: [String: AnyObject]) {
        //parsing here
        self.init(email: "", profileImage: nil, votes: [:], uploaded: [])
    }
    
    
    
}
