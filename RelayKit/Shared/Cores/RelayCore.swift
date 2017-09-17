//
//  RelayCore.swift
//  RelayKit
//
//  Created by David Moeller on 16.09.17.
//  Copyright © 2017 David Moeller. All rights reserved.
//

import Foundation
import WatchConnectivity


protocol RelayCore: class {
    
    var didReceiveMessage: (_ message: [String: Any], _ replyHandler: (([String: Any]) -> Void)?) -> Void { get set }
    var didReceiveUserInfo: (_ userInfo: [String: Any]) -> Void { get set }
    
    func sendMessage(_ data: [String: Any], replyHandler: @escaping ([String: Any]) -> Void, errorHandler: @escaping (Error) -> Void)
    func transferUserInfo(_ data: [String: Any])
}

class SimpleCore: RelayCore {
    
    var didReceiveMessage: ([String : Any], (([String : Any]) -> Void)?) -> Void
    var didReceiveUserInfo: ([String : Any]) -> Void
    
    init() {
        self.didReceiveMessage = { _, _ in }
        self.didReceiveUserInfo = { _ in }
    }
    
    func sendMessage(_ data: [String : Any], replyHandler: @escaping ([String : Any]) -> Void, errorHandler: @escaping (Error) -> Void) {
        self.didReceiveMessage(data, replyHandler)
    }
    
    func transferUserInfo(_ data: [String : Any]) {
        self.didReceiveUserInfo(data)
    }
    
    
    
    
}
