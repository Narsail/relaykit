//
//  WatchConnectivityCoreIOS.swift
//  iOS Framework
//
//  Created by David Moeller on 16.09.17.
//  Copyright © 2017 David Moeller. All rights reserved.
//

import Foundation
import WatchConnectivity


class WatchConnectivityCoreIOS: WatchConnectivityCore {
    
    override init() {
        super.init()
        self.wcSession.delegate = self
    }
    
}

extension WatchConnectivityCoreIOS: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        return
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        return
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        return
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        self.didReceiveMessage(message, WatchConnectivityCoreMethod.sendMessage, nil)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        self.didReceiveMessage(message, WatchConnectivityCoreMethod.sendMessage, replyHandler)
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        self.didReceiveMessage(userInfo, WatchConnectivityCoreMethod.transferUserInfo, nil)
    }
    
}
