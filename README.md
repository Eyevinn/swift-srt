# SwiftSRT
Bindings for [SRT](https://github.com/Haivision/srt) in Swift.

Using SRT version 1.4.3.

## Supported platforms
* iOS/iPadOS
* iOS/iPadOS Simulator (Intel Macs)
* macOS (Intel)

More platforms will be supported in the future.

## Usage
The easiest way to use the framework is to build a .xcframework-file. This can be done by running the script `build-xcframework.sh`. After running the script, you should find `build/swift-srt.xcframework` which you can simply drag and drop in to the "Frameworks, Libraries, and Embedded Content"-list in Xcode.

Support for Cocoapods is coming soon.

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
