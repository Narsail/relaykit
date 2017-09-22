//
//  Relay.swift
//  RelayKit
//
//  Created by David Moeller on 16.09.17.
//  Copyright © 2017 David Moeller. All rights reserved.
//

import Foundation
import WatchConnectivity

public enum RelayError: Error {
    case moduleIdentNotFound
    case messageIdentNotFound
    case noMessageTypeMatchFor(messageIdent: String)
    case receiverNotFound
}

public class Relay: NSObject {
    
    /// Last initiated Relay
    public static var shared: Relay?
    
    internal var core: RelayCore
    
    internal var sender: [String: (Sender, [Message.Type])] = [:]
    internal var receiver: [String: (Receiver, [Message.Type])] = [:]
    
    public var errorHandler: ((Error) -> Void)? = nil
    
    internal init(core: RelayCore) {
        
        self.core = core

        super.init()
        
        // Attach the receiving end of the core to the receivers
        
        self.core.didReceiveMessage = { [weak self] data, method, replyHandler in
            
            // Check for the Module Indent
            do {
                guard let moduleIdent = data["moduleIdent"] as? String else { throw RelayError.moduleIdentNotFound }
                
                // Check for the receiver
                guard let (receiver, messageTypes) = self?.receiver[moduleIdent] else { throw RelayError.receiverNotFound }
                
                // Check for the Message Ident
                guard let messageIdent = data["messageIdent"] as? String else { throw RelayError.messageIdentNotFound }
                
                // Get the appropriate Message Type
                guard let messageType = messageTypes.first(where: { $0.messageIdent == messageIdent }) else { throw RelayError.noMessageTypeMatchFor(messageIdent: messageIdent) }
                
                let message = try messageType.decode(data)
                
                if let replyHandler = replyHandler {
                    receiver.didReceiveMessage(message, method, { data in replyHandler(data.encode()) })
                } else {
                    receiver.didReceiveMessage(message, method, nil)
                }
                
            } catch {
                self?.errorHandler?(error)
            }
            
        }
        
        Relay.shared = self
        
    }
    
    /// Registering a Sender can only be done once per object
    ///
    /// - note: A followed call with the same sender will overwrite the old one
    
    public func register(_ sender: Sender, with messages: Message.Type ...) {
        self.register(sender, with: messages)
    }
    
    /// Registering a Sender can only be done once per object
    ///
    /// - note: A followed call with the same sender will overwrite the old one
    
    public func register(_ sender: Sender, with messages: [Message.Type]) {
        
        self.sender[sender.moduleIdent] = (sender, messages)
        
        // Set the necessary blocks
        sender.sendMessageBlock = { [weak self] message, method, replyHandler, errorHandler in
            
            // Error Handling if wrong Method
            
            var data = message.encode()
            data["moduleIdent"] = sender.moduleIdent
            data["messageIdent"] = type(of: message).messageIdent
            
            do {
                try self?.core.sendMessage(data, method, replyHandler: { replyData in
                    do {
                        // Find Message ident
                        guard let messageIdent = replyData["messageIdent"] as? String else { throw RelayError.messageIdentNotFound }
                        // Find a suitable Message to return
                        guard let messageClass = messages.first(where: { $0.messageIdent == messageIdent }) else { throw RelayError.noMessageTypeMatchFor(messageIdent: messageIdent) }
                        replyHandler(try messageClass.decode(replyData))
                    } catch {
                        errorHandler(error)
                    }
                }, errorHandler: errorHandler)
            } catch {
                errorHandler(error)
            }
            
        }
        
    }
    
    /// Registering a Receiver can only be done once per object
    
    public func register(_ receiver: Receiver, with messages: Message.Type ...) {
        
        self.register(receiver, with: messages)
        
    }
    
    /// Registering a Receiver can only be done once per object
    
    public func register(_ receiver: Receiver, with messages: [Message.Type]) {
        
        self.receiver[receiver.moduleIdent] = (receiver, messages)
        
    }
    
    /// Registering a Communicator can only be done once per object
    
    public func register(_ allrounder: Allrounder, with messages: Message.Type ...) {
        
        self.register(allrounder, with: messages)
        
    }
    
    public func register(_ allrounder: Allrounder, with messages: [Message.Type]) {
        
        self.register(allrounder as Sender, with: messages)
        self.register(allrounder as Receiver, with: messages)
        
    }
    
    public func deregister(_ sender: Sender) {
        
        // Set the Blocks nil
        sender.sendMessageBlock = nil
        
        self.sender.removeValue(forKey: sender.moduleIdent)
        
    }
    
    public func deregister(_ receiver: Receiver) {
        
        self.receiver.removeValue(forKey: receiver.moduleIdent)
        
    }
    
    public func deregister(_ allrounder: Allrounder) {
        
        self.deregister(allrounder as Sender)
        self.deregister(allrounder as Receiver)
        
    }
    
}
