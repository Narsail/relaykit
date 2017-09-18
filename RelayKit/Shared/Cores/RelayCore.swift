//
//  RelayCore.swift
//  RelayKit
//
//  Created by David Moeller on 16.09.17.
//  Copyright © 2017 David Moeller. All rights reserved.
//

import Foundation
import WatchConnectivity

enum RelayCoreError: Error {
    case wrongMethodType
}

protocol RelayCore: class {
    
    static var methodType: Method.Type { get }
    
    var didReceiveMessage: (_ message: [String: Any], _ method: Method, _ replyHandler: (([String: Any]) -> Void)?) -> Void { get set }
    
    func sendMessage(_ data: [String: Any], _ method: Method, replyHandler: @escaping ([String: Any]) -> Void, errorHandler: @escaping (Error) -> Void) throws
}

class SimpleCore: RelayCore {
    
    enum SimpleCoreMethod: Method {
        case sendMessage
    }
    
    static let methodType: Method.Type = SimpleCoreMethod.self
    
    var didReceiveMessage: ([String : Any], Method, (([String : Any]) -> Void)?) -> Void
    
    init() {
        self.didReceiveMessage = { _, _, _ in }
    }
    
    func sendMessage(_ data: [String : Any], _ method: Method, replyHandler: @escaping ([String : Any]) -> Void, errorHandler: @escaping (Error) -> Void) throws {
        
        guard let method = method as? SimpleCoreMethod else { throw RelayCoreError.wrongMethodType }
        
        self.didReceiveMessage(data, method, replyHandler)
    }
    
}
