//
//  server.swift
//  sample-server
//
//  Created by Jesper Lundqvist on 2021-08-23.
//

import Foundation
import SwiftSRT

@main
struct App {
    static func main() {
        // Start server
        let hostUrl = URL(string: "srt://0.0.0.0:1234")!
        let server = try! SRTServer(url: hostUrl)

        // Print all messages that the server receives
        let cancellable = server.publisher.sink { data in
            print(String(data: data, encoding: .utf8)!)
        }

        print("Listening to " + hostUrl.absoluteString)

        // Start server and print errors
        server.start() { error in
            print("Server error: " + error.localizedDescription)
        }
        
        // Create socket and write data
        let serverUrl = URL(string: "srt://127.0.0.1:1234")!
        print("Connecting to " + serverUrl.absoluteString)
        let socket = SRTSocket()
        do {
            try socket.connect(to: serverUrl)
            try socket.write(data: "Hello!".data(using: .utf8)!)
        }
        catch {
            print("Connection error: \(error.localizedDescription)")
        }
        
        server.stop()

        // Wait until the server has stopped.
        // This is because it is async and will not immediately stop when .stop() is called.
        Thread.sleep(forTimeInterval: 0.5)
        socket.close()
    }
}
