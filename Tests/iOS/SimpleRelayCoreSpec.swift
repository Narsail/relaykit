//
//  SimpleRelayCoreSpec.swift
//  RelayKit
//
//  Created by David Moeller on 17.09.17.
//Copyright © 2017 David Moeller. All rights reserved.
//

import Quick
import Nimble
@testable import RelayKit


class SimpleRelayCoreSpec: QuickSpec {
    
    override func spec() {
        
        describe("a simple Relay Core") {
            
            var core: SimpleCore!
            var sampleData: [String: Any]!
                
            beforeEach {
                core = SimpleCore()
                sampleData = [
                    "description": "Test Message"
                ]
            }
            
            describe("sending Messages through the Core") {
                
                it("sends a Message without a replyHandler") {
                    
                    core.didReceiveMessage = { data, replyHandler in
                        expect(data["description"] as? String).to(equal("Test Message"))
                        
                        // Create a new Message
                        replyHandler!(["description": "Reply. Thanks!"])
                    }
                    
                    core.sendMessage(sampleData, replyHandler: { replyData in
                        
                        expect(replyData["description"] as? String).to(equal("Reply. Thanks!"))
                        
                    }, errorHandler: { _ in })
                    
                    
                }
                
                it("transfering a User Info") {
                    
                    core.didReceiveUserInfo = { data in
                        expect(data["description"] as? String).to(equal("Test Message"))
                    }
                    
                    core.transferUserInfo(sampleData)
                    
                }
            }
            
        }
    }
    
}
