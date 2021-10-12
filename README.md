# SwiftSRT
Bindings for [SRT](https://github.com/Haivision/srt) in Swift. Maintained by [Eyevinn Technology](https://www.eyevinntechnology.se/).

Using SRT version 1.4.3.

You can start a server as follows: 

```swift
    // Start server
    let hostUrl = URL(string: "srt://0.0.0.0:1234")!
    let server = try! SRTServer(url: hostUrl)

    // Print all messages that the server receives (just for example)
    let cancellable = server.publisher.sink { data in
        print(String(data: data, encoding: .utf8)!)
    }

    print("Listening to " + hostUrl.absoluteString)

    // Start server and print errors
    server.start() { error in
        print("Server error: " + error.localizedDescription)
    }
```

And to write data to it, you create a socket and connect it as follows:

```swift
    // Print all messages that the server receives
    let cancellable = server.publisher.sink { data in
        print(String(data: data, encoding: .utf8)!)
    }

    print("Listening to " + hostUrl.absoluteString)

    // Start server and print errors
    server.start() { error in
        print("Server error: " + error.localizedDescription)
    }
```

NB: Remember to stop the server and close the socket after use:

```swift
    server.stop()
    socket.close()
```

See the full example in the `samples/server`-folder.

You can also create a stream that will output data to handle via a delegate. Create the stream as follows:

```swift
    // Initialise stream (and start server)
    let serverUrl = URL(string: "srt://127.0.0.1:1234")!
    let stream = try! SRTStream(serverUrl: serverUrl)
```

A class designed to write or otherwise handle the data stream can maintain a `TSWriterDelegate`:

```swift
class TSWriter {
    ...
    private var delegate: TSWriterDelegate
    ...
    public func aWriterFunc () {
        ...
        let dataBlock: Data? = "dataBlock".data(using: .utf8)

        self.delegate.didOutput(dataBlock!)
        ...
    }
}
```

NB: The SRTStream will close the underlying socket on destruction, but you can close() explicitly if you wish.

See the full example in the `samples/stream`-folder.


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

## A further simple example
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
