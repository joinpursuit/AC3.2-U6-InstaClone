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
        // Checks to see if user voted
        if let currentUser = FIRAuth.auth()?.currentUser?.uid {
            FIRDatabase.database().reference().child("users").child(currentUser).child("votes").observeSingleEvent(of: .value, with: { (snapshot: FIRDataSnapshot) in
                let value = snapshot.value as? NSDictionary
                let voted = value?[photoID.key] as? [String : AnyObject]
                if voted != nil {
                    
                    // If user did voted, check to see whether the vote is the same
                    if voted?["value"] as! Bool == upvoted {
                        // If vote is the same, do nothing
                        return
                    }
                    else {
                        // If vote is different, switch the vote
                        actualVote(for: photoID, upvoted: upvoted, switched: true)
                    }
                }
                else {
                    // If user didn't vote, vote now!
                    actualVote(for: photoID, upvoted: upvoted, switched: false)
                }
            })
        }
    }
    
    static func actualVote(for photoID: FIRDatabaseReference, upvoted: Bool, switched: Bool) {
        // [START photo_vote_transaction]
        photoID.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var data = currentData.value as? [String: AnyObject],
                var votes = data["votes"] as? [String: Int],
                var upvotes = votes["upvotes"],
                var downvotes = votes["downvotes"] {
                
                switch switched {
                case false:
                    if upvoted {
                        upvotes += 1
                    }
                    else {
                        downvotes += 1
                    }
                    
                case true:
                    if upvoted {
                        upvotes += 1
                        downvotes -= 1
                    }
                    else {
                        upvotes -= 1
                        downvotes += 1
                    }
                }
                
                votes["upvotes"] = upvotes
                votes["downvotes"] = downvotes
                data["votes"] = votes as AnyObject?
                currentData.value = data
                
                return FIRTransactionResult.success(withValue: currentData)
            } else {
                print("you failed at life")
            }
            return FIRTransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        // [END photo_vote_transaction]
        
        let date = Date()
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateStringFormatter.string(from: date)
        dateStringFormatter.dateFormat = "HH:mm:ss"
        let timeString = dateStringFormatter.string(from: date)
        
        let currentUserString = (FIRAuth.auth()?.currentUser?.uid)!
        let photoIDString = URL(string: photoID.description())!.lastPathComponent
        
        // [START vote_vote_transaction]
        let databaseVoteReference = FIRDatabase.database().reference().child("votes").child(photoIDString).child(currentUserString)
        databaseVoteReference.updateChildValues(["value" : upvoted])
        databaseVoteReference.updateChildValues(["time": timeString])
        databaseVoteReference.updateChildValues(["date": dateString])
        // [END vote_vote_transaction]
        
        // [START user_vote_transaction]
        let userVoteReference = FIRDatabase.database().reference().child("users").child(currentUserString).child("votes").child(photoIDString)
        userVoteReference.updateChildValues(["value" : upvoted] )
        userVoteReference.updateChildValues(["time": timeString])
        userVoteReference.updateChildValues(["date": dateString])
        // [END user_vote_transaction]
    }
}
