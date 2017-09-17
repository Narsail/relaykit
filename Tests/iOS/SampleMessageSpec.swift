//
//  SampleMessageSpec.swift
//  RelayKit
//
//  Created by David Moeller on 17.09.17.
//Copyright © 2017 David Moeller. All rights reserved.
//

import Quick
import Nimble

class SampleMessageSpec: QuickSpec {
    
    override func spec() {
        
        describe("create a Sample Message") {
            
            var message: SampleMessage!
            
            beforeEach {
                message = SampleMessage(description: "Test Message")
            }
            
            it("encode and decode it") {
                
                let data = message.encode()
                
                expect((try! SampleMessage.decode(data)).description).to(equal(message.description))
                
            }
            
        }

    }
    
}
