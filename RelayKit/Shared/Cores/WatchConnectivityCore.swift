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
    
    enum WatchConnectivityCoreMethod: Method {
        case sendMessage
        case transferUserInfo
    }
    
    static let methodType: Method.Type = WatchConnectivityCoreMethod.self
    
    var didReceiveMessage: ([String : Any], Method, (([String : Any]) -> Void)?) -> Void
    
    let wcSession = WCSession.default
    
    override init() {
        wcSession.activate()
        
        self.didReceiveMessage = { _, _, _ in }
        
        super.init()
    }
    
    func sendMessage(_ data: [String : Any], _ method: Method, replyHandler: @escaping ([String : Any]) -> Void, errorHandler: @escaping (Error) -> Void) throws {
        
        guard let method = method as? WatchConnectivityCoreMethod else { throw RelayCoreError.wrongMethodType }
        
        switch method {
        case .sendMessage:
            self.wcSession.sendMessage(data, replyHandler: replyHandler, errorHandler: errorHandler)
        case .transferUserInfo:
            self.wcSession.transferUserInfo(data)
        }
        
    }
    
}
