//
//  stream.swift
//  sample
//
//  Created by Eyevinn on 2021-09-29.
//

import Foundation
import SwiftSRT

@main
struct App {
    static func main() {
        // Start server
        let hostUrl = URL(string: "srt://0.0.0.0:1234")!
        let server = try! SRTServer(url: hostUrl)

        // Print all messages that the server recieves
        let cancellable = server.publisher.sink { data in
            print(String(data: data, encoding: .utf8)!)
        }

        print("Listening to " + hostUrl.absoluteString)

        // Start server and print errors
        server.start() { error in
            print("Server error: " + error.localizedDescription)
        }

        // Initialise stream (and start server)
        let serverUrl = URL(string: "srt://0.0.0.0:1234")!
        let stream = try! SRTStream(serverUrl: serverUrl)
        _ = DummyWriter(timeInterval: 1.0, numWrites: 4, stream: stream)
        
        stream.close()
        server.stop()
        RunLoop.current.run()
    }
}

class DummyWriter {
    private var timer: Timer?
    private var runCount: Int = 0
    private var numWrites: Int = 0
    private var timeInterval: TimeInterval?
    private var delegate: TSWriterDelegate
    
    init(timeInterval: TimeInterval, numWrites: Int, stream: TSWriterDelegate) {
        self.timeInterval = timeInterval
        self.numWrites = numWrites
        self.delegate = stream
        // set up timer
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            self.runCount += 1
            let dataBlock: Data? = "dataBlock \(self.runCount)".data(using: .utf8)
            self.delegate.didOutput(dataBlock!)
            if(self.runCount == self.numWrites) {
                timer.invalidate()
            }
        })
    }
    
    deinit {
        // destroyTimer
        if(timer!.isValid) {
            timer!.invalidate()
        }
    }
}
