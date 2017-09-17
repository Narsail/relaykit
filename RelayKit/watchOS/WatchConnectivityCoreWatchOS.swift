//
//  WatchConnectivityCoreWatchOS.swift
//  watchOS Framework
//
//  Created by David Moeller on 16.09.17.
//  Copyright © 2017 David Moeller. All rights reserved.
//

import Foundation
import WatchConnectivity

class WatchConnectivityCoreWatchOS: WatchConnectivityCore {
    
    override init() {
        super.init()
        self.wcSession.delegate = self
    }
    
}

extension WatchConnectivityCoreWatchOS: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        return
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        self.didReceiveMessage(message, nil)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        self.didReceiveMessage(message, replyHandler)
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        self.didReceiveUserInfo(userInfo)
    }
    
}
