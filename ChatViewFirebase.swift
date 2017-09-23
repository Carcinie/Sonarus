//
//  ChatViewFirebase.swift
//  Sonarus
//
//  Created by Christopher Arciniega on 5/12/17.
//  Copyright © 2017 HQZenithLabs. All rights reserved.
//

import Foundation

extension ChatViewController{
    
    
    
    func fireGetRooms(){
       //let  groupRef:FIRDatabaseReference = FIRDatabase.database().reference().child("Roombase")
    
    }
    func fireListenForMessages(){
        let room = UserVariables.activeRoom
        print("listening to room \(room)")
        let refRoom = FIRDatabase.database().reference().child("Roombase/\(room)/5Messages/")
        
        refRoom.queryLimited(toLast: 1).observe(.value, with: {snapshot in
            for msg in snapshot.children.allObjects as! [FIRDataSnapshot]{
                let msgObject = msg.value as? [String: AnyObject]
                let msgText = msgObject?["msg"]
                let msgSender = msgObject?["from"]
                //let timeStamp = msgObject?["time"]
                
                //Create Sonarus message object to display
                var m:Message
                if msgSender  != nil{
                    //print(msgText as! String)
                    if msgSender as! String == UserVariables.userID{
                        m = Message(Message: msgText as! String, Sender: msgSender as! String, incoming: false)
                    }
                    else{
                        m = Message(Message: msgText as! String, Sender: msgSender as! String, incoming: true)
                    }
                    self.messages.append(m)
                }
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: "FIRMessageAdded"), object: nil)
        })
    }

    func fireSendMessage(message:String, room:String){
        //Generate key
        print("sending message to room \(room)" )
        let refMessages = FIRDatabase.database().reference().child("Roombase/\(room)/5Messages/")
        let key = refMessages.childByAutoId().key
        let timestamp = "\(0 - (NSDate().timeIntervalSince1970))"
        //Create message
        var name = ""
        if UserVariables.userName == ""{
            name = UserVariables.userID
        }
        else{
            name = UserVariables.userName
        }
        let m = ["from":name, "msg":message, "time": timestamp]
        print(m)
        print(UserVariables.userName)
        //self.messages.append(Message.init(Message: message, Sender: username, incoming: false))
        //Add message to generated key
        refMessages.child(key).setValue(m)
        print("Message sent")
    }
    func fireFollowGroup(){
        
    }
    
}
