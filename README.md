# RelayKit

Currently the WatchConnectivity Framework of iOS and watchOS can only handle one delegate. In the Application of my current Startup [Evomo][Evomo] we have multiple frameworks independently talking to their counterpart on the Apple Watch. To handle the Messages between the Sender and its paired Receiver efficiently we developed **RelayKit**.

![badge-pod] ![badge-languages] ![badge-pms] ![badge-platforms] [![Build Status](https://travis-ci.org/Narsail/relaykit.svg?branch=master)](https://travis-ci.org/Narsail/relaykit)

[Evomo]: www.evomo.de

## Installation
### CocoaPods
[CocoaPods][] is a dependency manager for Cocoa projects. To install RelayKit with CocoaPods:

 1. Make sure CocoaPods is [installed][CocoaPods Installation].

 2. Update your Podfile to include the following:

    ``` ruby
    use_frameworks!
    pod 'RelayKit'
    ```

 3. Run `pod install`.

[CocoaPods]: https://cocoapods.org
[CocoaPods Installation]: https://guides.cocoapods.org/using/getting-started.html#getting-started
 
 4. In your code import RelayKit like so:
   `import RelayKit`
   
## Usage
### To supplement Watch Connectivity
#### Create a Relay

```swift
// On iOS Side
let core = WatchConnectivityCoreIOS()
let relay = Relay(core: core)

// You can access thie relay now anywhere through the shared variable
Relay.shared 

// WatchOS Side
let core = WatchConnectivityCoreWatchOS()
let relay = Relay(core: core)
```

#### Create and Register a Sender
```swift
// To actually send something let your class conform to the Sender protocol
class SenderExample: Sender {
    // This Ident is necessary to match it to its receiver pair
    var moduleIdent: String = "SamplePair"
    
    // This one is necessary for the internal mechanism, it can be nil, no default necessary
    var sendMessageBlock: ((Message, SendingMethod, @escaping (Message) -> Void, @escaping (Error) -> Void) -> Void)?

}

let sender = SenderExample()

// And register it to the relay
relay.register(sender)
```
#### Create and Register a Receiver

```swift

// The Receiver must conform to the Receiver Protocol

class SampleReceiver: Receiver {
    
    var moduleIdent: String = "SamplePair"
    
    var message: Message? = nil
    
    func didReceiveMessage(_ message: Message, _ method: SendingMethod, _ replyHandler: ((Message) -> Void)?) {
        self.message = message
    }
    
}

receiver = SampleReceiver()

relay.register(receiver)

```

#### Send a Message
```swift
// To send something it is important to use the correct SendingMethod of the Core you use
// for the WatchConnectivity Core it is as follows:

enum WatchConnectivityCoreMethod: SendingMethod {
        case sendMessage
        case transferUserInfo
}

// Conform to the Message Protocol
struct SampleMessage: Message {
    
    static var messageIdent: String = "SampleMessage"
    
    public let description: String
    
    func encode() -> [String : Any] {
        return [
            "description": description
        ]
    }
    
    static func decode(_ data: [String : Any]) throws -> SampleMessage {
        
        guard let description = data["description"] as? String else { throw MessageError.keyNotFound(key: "description") }
        
        return SampleMessage(description: description)
        
    }
    
}

// Send it
sender.sendMessage(SampleMessage(), WatchConnectivityCoreMethod.sendMessage)
```

#### Deregister

```swift

// If you are done you can deregister the sender and receiver
relay.deregister(sender)
relay.deregister(receiver)

```


[badge-pod]: https://img.shields.io/cocoapods/v/RelayKit.svg?label=version
[badge-pms]: https://img.shields.io/badge/supports-CocoaPods-green.svg
[badge-languages]: https://img.shields.io/badge/languages-Swift-orange.svg
[badge-platforms]: https://img.shields.io/badge/platforms-iOS%20%7C%20watchOS-lightgrey.svg
[badge-mit]: https://img.shields.io/badge/license-MIT-blue.svg

<!-- https://img.shields.io/badge/supports-CocoaPods%20%7C%20Carthage%20%7C%20SwiftPM-green.svg -->
