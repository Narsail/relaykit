/// Copyright (c) 2017 David Moeller
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import WatchConnectivity

public enum RelayError: Error {
    case moduleIdentNotFound
    case messageIdentNotFound
    case noMessageTypeMatchFor(messageIdent: String)
    case receiverNotFound
}

open class Relay: NSObject {
    
    /// Last initiated Relay
    public static var shared: Relay? {
        didSet {
            debugLog(RelayKitLogCategory.configuration,
                     ["Setting", type(of: shared), "as Relay with", type(of: shared?.core), "."])
        }
    }
    
    internal var core: RelayCore
    
    internal var sender: [String: (Sender, [Message.Type])] = [:]
    internal var receiver: [String: (Receiver, [Message.Type])] = [:]
    
    public var errorHandler: ((Error) -> Void)? = nil
    
    public init(core: RelayCore) {
        
        self.core = core

        super.init()
        
        // Attach the receiving end of the core to the receivers
        
        self.core.didReceiveMessage = { [weak self] data, method, replyHandler in
            
            // Check for the Module Indent
            do {
                
                debugLog(.messages, ["Received Message Data", data])
                
                guard let moduleIdent = data["moduleIdent"] as? String else { throw RelayError.moduleIdentNotFound }
                
                // Check for the receiver
                guard let (receiver, messageTypes) = self?.receiver[moduleIdent] else { throw RelayError.receiverNotFound }
                
                // Check for the Message Ident
                guard let messageIdent = data["messageIdent"] as? String else { throw RelayError.messageIdentNotFound }
                
                // Get the appropriate Message Type
                guard let messageType = messageTypes.first(where: { $0.messageIdent == messageIdent }) else { throw RelayError.noMessageTypeMatchFor(messageIdent: messageIdent) }
                
                let message = try messageType.decode(data)
                
                debugLog(.messages, ["Received", messageType, "with", method])
                
                if let replyHandler = replyHandler {
                    receiver.didReceiveMessage(message, method, { replyMessage in
                        
                        var encodedData = replyMessage.encode()
                        
                        encodedData["moduleIdent"] = moduleIdent
                        encodedData["messageIdent"] = type(of: replyMessage).messageIdent
                        
                        replyHandler(encodedData)
                    })
                } else {
                    receiver.didReceiveMessage(message, method, nil)
                }
                
            } catch {
                debugLog(.messages, ["Receiving message failed with", error, "by", method])
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
            
            debugLog(.messages, ["Sending Message", type(of: message), "with", method])
            
            // Error Handling if wrong Method
            var data = message.encode()
            data["moduleIdent"] = sender.moduleIdent
            data["messageIdent"] = type(of: message).messageIdent
            
            debugLog(.messageContent, ["Sending Message Data", data])
            
            do {
                try self?.core.sendMessage(data, method, replyHandler: { replyData in
                    do {
                        
                        debugLog(.messageContent, ["Got Reply Data with", replyData])
                        // Find Message ident
                        guard let messageIdent = replyData["messageIdent"] as? String else {
                            throw RelayError.messageIdentNotFound
                        }
                        // Find a suitable Message to return
                        guard let messageClass = messages.first(where: { $0.messageIdent == messageIdent }) else {
                            throw RelayError.noMessageTypeMatchFor(messageIdent: messageIdent)
                        }
                        let responseMessage = try messageClass.decode(replyData)
                        
                        debugLog(.messages, ["Got Reply with", type(of: message), "with", method])
                        
                        replyHandler(responseMessage)
                    } catch {
                        debugLog(.messages, ["Receiving reply failed with", error, "by", method])
                        errorHandler(error)
                    }
                }, errorHandler: errorHandler)
            } catch {
                debugLog(.messages, ["Sending message failed with", error, "by", method])
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
