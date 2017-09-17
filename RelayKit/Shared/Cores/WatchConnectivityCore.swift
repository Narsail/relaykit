//
//  WatchConnectivityCore.swift
//  RelayKit
//
//  Created by David Moeller on 16.09.17.
//  Copyright © 2017 David Moeller. All rights reserved.
//

import Foundation
import WatchConnectivity

class WatchConnectivityCore: NSObject, RelayCore {
    
    var didReceiveMessage: ([String : Any], (([String : Any]) -> Void)?) -> Void
    
    var didReceiveUserInfo: ([String : Any]) -> Void
    
    let wcSession = WCSession.default
    
    override init() {
        wcSession.activate()
        
        self.didReceiveMessage = { _, _ in }
        self.didReceiveUserInfo = { _ in }
        
        super.init()
    }
    
    func sendMessage(_ data: [String : Any], replyHandler: @escaping ([String : Any]) -> Void, errorHandler: @escaping (Error) -> Void) {
        self.wcSession.sendMessage(data, replyHandler: replyHandler, errorHandler: errorHandler)
    }
    func transferUserInfo(_ data: [String : Any]) {
        self.wcSession.transferUserInfo(data)
    }
    
}
