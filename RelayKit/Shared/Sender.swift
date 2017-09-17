//
//  Sender.swift
//  RelayKit
//
//  Created by David Moeller on 16.09.17.
//  Copyright © 2017 David Moeller. All rights reserved.
//

import Foundation

public enum SenderError: Error {
    case notRegistered
}

/// The Sender of a message

public protocol Sender: class {
    
    /// The ident to pair a sender to its receiver
    
    var moduleIdent: String { get set }
    
    var sendMessageBlock: ((_ message: Message, _ replyHandler: @escaping (_ message: Message) -> Void, _ errorHandler: @escaping (_ error: Error) -> Void) -> Void)? { get set }
    var transferUserInfoBlock: ((_ message: Message) -> Void)? { get set }
    
    func sendMessage(_ message: Message, _ replyHandler: ((_ message: Message) -> Void)?, _ errorHandler: ((_ error: Error) -> Void)?)
    func transferUserInfo(_ message: Message)
}

public extension Sender {
    
    /// Send a Message to the Receiver
    ///
    /// If the Sender is not registered no MessageBlock will be assigned -> The Message won't be send anywhere and an
    /// Error gets thrown.
    
    public func sendMessage(_ message: Message, _ replyHandler: ((_ message: Message) -> Void)?, _ errorHandler: ((_ error: Error) -> Void)?) {
        
        if let messageBlock = self.sendMessageBlock {
            messageBlock(
                message,
                { response in
                    replyHandler?(response)
                },
                { error in
                    errorHandler?(error)
                }
            )
            return
        }
        errorHandler?(SenderError.notRegistered)
    }
    
    public func transferUserInfo(_ message: Message) {
        if let messageBlock = self.transferUserInfoBlock {
            messageBlock(message)
        }
    }
    
}