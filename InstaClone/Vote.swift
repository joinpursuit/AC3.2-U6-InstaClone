//
//  Vote.swift
//  InstaClone
//
//  Created by Tong Lin on 2/8/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

class Vote {
    let voteID: String
    var activities: [String: Bool]
    
    init(voteID: String, activities: [String: Bool]) {
        self.voteID = voteID
        self.activities = activities
    }
    
    static func voted(for photoID: FIRDatabaseReference, upvoted: Bool) {
        
        // [START photo_vote_transaction]
        photoID.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var data = currentData.value as? [String : AnyObject] {
                var votes = data["vote"] as! [String : Int]
                var upvotes = votes["upvotes"]!
                var downvotes = votes["downvotes"]!
                
                if upvoted {
                    upvotes += 1
                }
                else {
                    downvotes += 1
                }
                
                votes["upvotes"] = upvotes
                votes["downvotes"] = downvotes
                
                currentData.value = data
                
                return FIRTransactionResult.success(withValue: currentData)
            }
            return FIRTransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        // [END photo_vote_transaction]
        
        let currentUserString = (FIRAuth.auth()?.currentUser?.uid)!
        let photoIDString = URL(string: photoID.description())!.lastPathComponent
        
        // [START vote_vote_transaction]
        let databaseVoteReference = FIRDatabase.database().reference().child("votes")
        databaseVoteReference.updateChildValues([currentUserString : upvoted])
        // [END vote_vote_transaction]
        
        // [START user_vote_transaction]
        let userVoteReference = FIRDatabase.database().reference().child("users").child(currentUserString).child("votes")
        userVoteReference.updateChildValues([photoIDString : upvoted])
        // [END user_vote_transaction]
    }
    
}
