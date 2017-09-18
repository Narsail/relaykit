//
//  Message.swift
//  RelayKit
//
//  Created by David Moeller on 16.09.17.
//  Copyright © 2017 David Moeller. All rights reserved.
//

import Foundation

/// Basic Protocol for a Message sent between an iOS Device and a watchOS Device

public protocol Message {
    
    /// The Message will be identified and distributed based on this Ident
    
    static var messageIdent: String { get }
    
    func encode() -> [String: Any]
    static func decode(_ data: [String: Any]) throws -> Self
    
}

public enum MessageError: Error {
    case keyNotFound(key: String)
}



