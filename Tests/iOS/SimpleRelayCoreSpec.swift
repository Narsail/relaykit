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
                
                it("sends a Message with the wrong Method Type") {
                    expect {try core.sendMessage([:], WatchConnectivityCore.WatchConnectivityCoreMethod.sendMessage, replyHandler: { _ in }, errorHandler: {_ in }) }.to(throwError(RelayCoreError.wrongMethodType))
                }
                
                it("sends a Message with a replyHandler") {

                    core.didReceiveMessage = { data, method, replyHandler in
                        expect(data["description"] as? String).to(equal("Test Message"))
                        expect(method).to(beAKindOf(SimpleCore.SimpleCoreMethod.self))
                        // Create a new Message
                        replyHandler!(["description": "Reply. Thanks!"])
                    }

                    try! core.sendMessage(sampleData, SimpleCore.SimpleCoreMethod.sendMessage, replyHandler: { replyData in

                        expect(replyData["description"] as? String).to(equal("Reply. Thanks!"))

                    }, errorHandler: { _ in })

                }

            }
            
        }
    }
    
}
