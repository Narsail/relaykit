//
//  Receiver.swift
//  RelayKit
//
//  Created by David Moeller on 16.09.17.
//  Copyright © 2017 David Moeller. All rights reserved.
//

import Foundation

public enum ReceiverError: Error {
    case methodNotImplemented
    case typeForIdentNotFound
}

public protocol Receiver: class {
    
    var moduleIdent: String { get set }
    
    func didReceiveMessage(_ message: Message, _ method: Method, _ replyHandler: ((_ message: Message) -> Void)?)
    
}
