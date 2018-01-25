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

public enum RelayCoreError: Error {
    case wrongMethodType
}

public protocol RelayCore: class {
    
    static var methodType: SendingMethod.Type { get }
    
    var didReceiveMessage: (_ message: [String: Any], _ method: SendingMethod, _ replyHandler: (([String: Any]) -> Void)?) -> Void { get set }
    
    func sendMessage(_ data: [String: Any], _ method: SendingMethod, replyHandler: @escaping ([String: Any]) -> Void, errorHandler: @escaping (Error) -> Void) throws
}

public class SimpleCore: RelayCore {
    
    public enum SimpleCoreMethod: SendingMethod {
        case sendMessage
    }
    
    static public let methodType: SendingMethod.Type = SimpleCoreMethod.self
    
    public var didReceiveMessage: ([String : Any], SendingMethod, (([String : Any]) -> Void)?) -> Void
    
    init() {
        self.didReceiveMessage = { _, _, _ in }
    }
    
    public func sendMessage(_ data: [String : Any], _ method: SendingMethod, replyHandler: @escaping ([String : Any]) -> Void, errorHandler: @escaping (Error) -> Void) throws {
        
        guard let method = method as? SimpleCoreMethod else { throw RelayCoreError.wrongMethodType }
        
        self.didReceiveMessage(data, method, replyHandler)
    }
    
}
