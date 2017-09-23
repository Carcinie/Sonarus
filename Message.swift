//
//  Message.swift
//  Sonarus
//
//  Created by Christopher Arciniega on 5/2/17.
//  Copyright © 2017 HQZenithLabs. All rights reserved.
//

import Foundation

class Message{
    var text : String?
    var sender : String?
    var incoming = true
    
    init(Message m:String, Sender s:String, incoming i:Bool){
        text = m
        sender = s
        incoming = i
    }
    
}
