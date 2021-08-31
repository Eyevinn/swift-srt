# SwiftSRT
Bindings for [SRT](https://github.com/Haivision/srt) in Swift. Maintained by [Eyevinn Technology](https://www.eyevinntechnology.se/).

Using SRT version 1.4.3.

## Supported platforms
* iOS/iPadOS
* iOS/iPadOS Simulator
* macOS

## Usage
SwiftSRT can be used with Swift Package Manager, Cocoapods, or by simply dragging the framework `Frameworks/SwiftSRT.xcframework` to the "Frameworks, Libraries, and Embedded Content"-list in Xcode.

### Cocoapods
Add SwiftSRT by adding the following to the desired target in your Podfile:
```
pod 'SwiftSRT', '~> 0.1'
```

### Swift Package Manager
To add SwiftSRT, your dependency list should look something like this:
```swift
dependencies: [
    .package(url: "https://github.com/Eyevinn/swift-srt", .upToNextMinor(from: "0.1.0"))
]
```

## Example
This simple example program will print the first data it recives as a base64 string.

```swift
import SwiftSRT

let url = URL(string: "srt://0.0.0.0:1234")!
let socket = SRTSocket()
try! socket.bind(to: url)
socket.listen(withBacklog: 2)
print("Listening to " + url.absoluteString)

let fd = socket.accept()
let chunk = fd.read(dataWithSize: 1316)
print(chunk.base64EncodedString())
```

There are more examples in the `samples`-folder.
