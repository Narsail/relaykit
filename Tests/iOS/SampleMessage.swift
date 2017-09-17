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
    
    let description: String
    
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
