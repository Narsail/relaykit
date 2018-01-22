//
//  WatchConnectivityCore.swift
//  RelayKit
//
//  Created by David Moeller on 16.09.17.
//  Copyright © 2017 David Moeller. All rights reserved.
//

import Foundation
import WatchConnectivity

public class WatchConnectivityCore: NSObject, RelayCore {
    
    public enum WatchConnectivityCoreMethod: SendingMethod {
        case sendMessage
        case transferUserInfo
    }
    
    static public let methodType: SendingMethod.Type = WatchConnectivityCoreMethod.self
    
    public var didReceiveMessage: ([String : Any], SendingMethod, (([String : Any]) -> Void)?) -> Void
    
    let wcSession = WCSession.default
    
    override init() {
        wcSession.activate()
        
        self.didReceiveMessage = { _, _, _ in }
        
        super.init()
    }
    
    public func sendMessage(_ data: [String : Any], _ method: SendingMethod, replyHandler: @escaping ([String : Any]) -> Void, errorHandler: @escaping (Error) -> Void) throws {
        
        guard let method = method as? WatchConnectivityCoreMethod else { throw RelayCoreError.wrongMethodType }
        
        switch method {
        case .sendMessage:
            self.wcSession.sendMessage(data, replyHandler: replyHandler, errorHandler: errorHandler)
        case .transferUserInfo:
            self.wcSession.transferUserInfo(data)
        }
        
    }
    
}
