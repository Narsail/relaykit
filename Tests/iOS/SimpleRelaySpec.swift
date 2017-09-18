//
//  SimpleRelaySpec.swift
//  RelayKit
//
//  Created by David Moeller on 19.09.17.
//Copyright © 2017 David Moeller. All rights reserved.
//

import Quick
import Nimble
@testable import RelayKit

class SimpleRelaySpec: QuickSpec {
    
    override func spec() {
        
        describe("a simple Relay") {
            
            var relay: Relay!
            
            beforeEach {
                relay = Relay(core: SimpleCore())
            }
            
            describe("Register and Unregister a Sender") {
                
                var sender: SampleSender!
                
                beforeEach {
                    sender = SampleSender()
                }
                
                it("register a Sender") {
                    
                    relay.register(sender, with: [SampleMessage.self])
                    
                    expect(relay.sender[sender.moduleIdent]?.0).to(beIdenticalTo(sender))
                    
                }
                
                it("deregister a Sender") {
                    
                    relay.register(sender, with: [SampleMessage.self])
                    
                    relay.deregister(sender)
                    
                    expect(relay.sender[sender.moduleIdent]).to(beNil())
                }
            }
            
            describe("Register and Unregister a Receiver") {
                
                var receiver: SampleReceiver!
                
                beforeEach {
                    receiver = SampleReceiver()
                }
                
                it("register a receiver") {
                    
                    relay.register(receiver, with: [SampleMessage.self])
                    
                    expect(relay.receiver[receiver.moduleIdent]?.0).to(beIdenticalTo(receiver))
                    
                }
                
                it("deregister a receiver") {
                    
                    relay.deregister(receiver)
                    
                    expect(relay.receiver[receiver.moduleIdent]).to(beNil())
                    
                }
                
            }
            
            describe("Sending a Message from a sender to a receiver") {
                
                var sender: SampleSender!
                var receiver: SampleReceiver!
                var passiveReceiver: SampleReceiver!
                
                beforeEach {
                    sender = SampleSender()
                    receiver = SampleReceiver()
                    passiveReceiver = SampleReceiver()
                    passiveReceiver.moduleIdent = "NotConnectedToTheSamplePair"
                }
                
                it("Send a Message") {
                    
                    let message = SampleMessage(description: "Test Message")
                    
                    relay.register(sender, with: [SampleMessage.self])
                    relay.register(receiver, with: [SampleMessage.self])
                    relay.register(passiveReceiver, with: [SampleMessage.self])
                    
                    sender.sendMessage(message, SimpleCore.SimpleCoreMethod.sendMessage, nil, nil)
                    
                    expect((receiver.message as? SampleMessage)?.description).to(equal(message.description))
                    expect(passiveReceiver.message).to(beNil())
                    
                }
                
                it("Send a message with a receiver with the wrong registered Message Type") {
                    let message = SampleMessage(description: "Test Message")
                    
                    relay.register(sender, with: [SampleMessage.self])
                    relay.register(receiver, with: [DummyMessage.self])
                    relay.register(passiveReceiver, with: [SampleMessage.self])
                    
                    sender.sendMessage(message, SimpleCore.SimpleCoreMethod.sendMessage, nil, nil)
                    
                    expect(receiver.message).to(beNil())
                    expect(passiveReceiver.message).to(beNil())
                }
                
            }
            
        }

    }
    
}
