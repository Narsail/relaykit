/// Copyright (c) 2017 David Moeller
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

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
