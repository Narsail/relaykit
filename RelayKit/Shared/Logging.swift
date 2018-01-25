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
///
/// This Code is based and inspired upon https://github.com/bustoutsolutions/siesta/blob/ce4ff32618db5c950696e53b8e7818fa10a8d20a/Source/Siesta/Support/Logging.swift
/// Copyright © 2016 Bust Out Solutions. All rights reserved.
///

import Foundation

/**
 Controls which message RelayKit will log. See `enabledLogCategories`.
*/

public enum RelayKitLogCategory {
    
    /// Details of when a relay is set.
    case configuration
    
    /// Details of the actual messaging
    case messages
    
    /// Details of the Message Content
    case messageContent
    
    // MARK: Predefined subsets
    
    /// The whole schebang!
    public static let all: Set<RelayKitLogCategory> = [configuration, messages, messageContent]
    
    /// The set of categories to log. Can be changed at runtime.
    public static var enabled = Set<RelayKitLogCategory>()
}

private let maxCategoryNameLength = RelayKitLogCategory.all.map { Int(String(describing: $0).count) }.max() ?? 0

/// Inject your custom logger to do something other than print to stdout.
public var logger: (RelayKitLogCategory, String) -> Void = {
    
    let paddedCategory = String(describing: $0).padding(toLength: maxCategoryNameLength, withPad: " ", startingAt: 0)
    let prefix = "RelayKit:\(paddedCategory) │ "
    let indentedMessage = $1.replacingOccurrences(of: "\n", with: "\n" + prefix)
    print(prefix + indentedMessage)
    
}

internal func debugLog(_ category: RelayKitLogCategory, _ messageParts: @autoclosure () -> [Any?]) {
    if RelayKitLogCategory.enabled.contains(category) {
        logger(category, debugStr(messageParts()))
    }
}

private let whitespacePat = try! NSRegularExpression(pattern: "\\s+")

internal func debugStr(_ x: Any?, consolidateWhitespace: Bool = false, truncate: Int? = 500) -> String {
    
    guard let x = x else { return "nil" }
    
    var s: String
    if let debugPrintable = x as? CustomDebugStringConvertible {
        s = debugPrintable.debugDescription
        
    } else { s = "\(x)" }
    
    if consolidateWhitespace {
        s = s.replacing(regex: whitespacePat, with: " ")
    }
    
    if let truncate = truncate, s.count > truncate {
        s = s.prefix(truncate) + "…"
    }
    
    return s
}

internal func debugStr(_ messageParts: [Any?], join: String = " ", consolidateWhitespace: Bool = true,
                       truncate: Int? = 300) -> String {
    
    return messageParts.map {
            ($0 as? String)
                ?? debugStr($0, consolidateWhitespace: consolidateWhitespace, truncate: truncate)
        }
        .joined(separator: " ")
}

internal extension String {
    func contains(regex: String) -> Bool {
        return range(of: regex, options: .regularExpression) != nil
    }
    
    func replacing(regex: String, with replacement: String) -> String {
        return replacingOccurrences(
            of: regex, with: replacement, options: .regularExpression, range: nil)
    }
    
    func replacing(regex: NSRegularExpression, with template: String) -> String {
        return regex.stringByReplacingMatches(in: self, options: [], range: fullRange, withTemplate: template)
    }
    
    fileprivate var fullRange: NSRange {
        return NSRange(location: 0, length: (self as NSString).length)
    }
}

internal extension NSRegularExpression {
    
    func matches(_ string: String) -> Bool {
        let match = firstMatch(in: string, options: [], range: string.fullRange)
        return match != nil && match?.range.location != NSNotFound
    }
}
