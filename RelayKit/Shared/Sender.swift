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

public enum SenderError: Error {
    case notRegistered
}

/// The Sender of a message

public protocol Sender: class {
    
    /// The ident to pair a sender to its receiver
    
    var moduleIdent: String { get set }
    
    var sendMessageBlock: ((_ message: Message, _ method: SendingMethod, _ replyHandler: @escaping (_ message: Message) -> Void, _ errorHandler: @escaping (_ error: Error) -> Void) -> Void)? { get set }
    
    func sendMessage(_ message: Message, _ method: SendingMethod, _ replyHandler: ((_ message: Message) -> Void)?, _ errorHandler: ((_ error: Error) -> Void)?)
}

public extension Sender {
    
    /// Send a Message to the Receiver
    ///
    /// If the Sender is not registered no MessageBlock will be assigned -> The Message won't be send anywhere and an
    /// Error gets thrown.
    
    public func sendMessage(_ message: Message, _ method: SendingMethod, _ replyHandler: ((_ message: Message) -> Void)?, _ errorHandler: ((_ error: Error) -> Void)?) {
        
        if let messageBlock = self.sendMessageBlock {
            messageBlock(
                message,
                method,
                { response in
                    replyHandler?(response)
                },
                { error in
                    errorHandler?(error)
                }
            )
            return
        }
        errorHandler?(SenderError.notRegistered)
    }
    
}
