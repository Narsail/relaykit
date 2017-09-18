//
//  SampleMessage.swift
//  iOS Framework Unit Tests
//
//  Created by David Moeller on 17.09.17.
//  Copyright © 2017 David Moeller. All rights reserved.
//

import Foundation
import RelayKit


struct SampleMessage: Message {
    
    static var messageIdent: String = "SampleMessage"
    
    public let description: String
    
    func encode() -> [String : Any] {
        return [
            "description": description
        ]
    }
    
    static func decode(_ data: [String : Any]) throws -> SampleMessage {
        
        guard let description = data["description"] as? String else { throw MessageError.keyNotFound(key: "description") }
        
        return SampleMessage(description: description)
        
    }
    
}

struct DummyMessage: Message {
    
    static var messageIdent: String = "DummyMessage"
    
    public let description: String
    
    func encode() -> [String : Any] {
        return [
            "description": description
        ]
    }
    
    static func decode(_ data: [String : Any]) throws -> DummyMessage {
        
        guard let description = data["description"] as? String else { throw MessageError.keyNotFound(key: "description") }
        
        return DummyMessage(description: description)
        
    }
    
}

class SampleSender: Sender {
    
    var moduleIdent: String = "SamplePair"
    
    var sendMessageBlock: ((Message, SendingMethod, @escaping (Message) -> Void, @escaping (Error) -> Void) -> Void)?
    
}

class SampleReceiver: Receiver {
    
    var moduleIdent: String = "SamplePair"
    
    var message: Message? = nil
    
    func didReceiveMessage(_ message: Message, _ method: SendingMethod, _ replyHandler: ((Message) -> Void)?) {
        self.message = message
    }
    
}
